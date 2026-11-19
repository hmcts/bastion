"""Validate one token-only Terraform change without exposing plan credentials."""

import argparse
import json
import re
import ssl
import sys
import urllib.error
import urllib.request


HOSTS = ("bastion-sbox", "bastion-secops-sbox", "bastion-nonprod")
HOST_RESOURCES = {
    "bastion-sbox": ("b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac", "bastion-sbox-rg"),
    "bastion-secops-sbox": ("b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac", "bastion-sbox-rg"),
    "bastion-nonprod": ("b44eb479-9ae2-42e7-9c63-f3c599719b6f", "bastion-nonprod-rg"),
}
TENANT_ID = "yrk32651"
SECRET_NAME = "dynatrace-nonprod-token"
SECRET_VERSION = "415d404470494d37a8ddc7d7ceac8a6a"
METADATA_URL = (
    f"https://{TENANT_ID}.live.dynatrace.com/api/v1/deployment/installer/"
    "agent/unix/default/latest/metainfo"
)


class RejectedPlan(Exception):
    """The exception messages contain fixed descriptions, never plan values."""


def target_address(host):
    if host not in HOSTS:
        raise RejectedPlan("Unsupported maintenance host.")
    return (
        f"module.{host}.module.virtual_machine_bootstrap."
        "azurerm_virtual_machine_extension.dynatrace_oneagent[0]"
    )


def virtual_machine_id(host):
    subscription, resource_group = HOST_RESOURCES[host]
    return (
        f"/subscriptions/{subscription}/resourceGroups/{resource_group}/"
        f"providers/Microsoft.Compute/virtualMachines/{host}"
    )


def has_unknown(value):
    if isinstance(value, dict):
        return any(has_unknown(item) for item in value.values())
    if isinstance(value, list):
        return any(has_unknown(item) for item in value)
    return value is True


def resources(module):
    yield from module.get("resources", [])
    for child in module.get("child_modules", []):
        yield from resources(child)


def settings(value):
    try:
        result = json.loads(value)
    except (TypeError, ValueError):
        raise RejectedPlan("Extension settings are not a JSON object.") from None
    if not isinstance(result, dict):
        raise RejectedPlan("Extension settings are not a JSON object.")
    return result


def validate_plan(plan, host):
    address = target_address(host)
    if not isinstance(plan, dict) or plan.get("errored") is True:
        raise RejectedPlan("Terraform plan is invalid or errored.")
    if plan.get("terraform_version") != "1.5.6":
        raise RejectedPlan("Unexpected Terraform version.")
    selected = []
    for item in plan.get("resource_changes", []):
        change = item.get("change", {})
        if item.get("mode") not in ("managed", "data"):
            raise RejectedPlan("Unexpected resource mode.")
        if item.get("mode") == "data":
            if change.get("actions") not in (["read"], ["no-op"]):
                raise RejectedPlan("Unexpected data resource action.")
            if has_unknown(change.get("after_unknown", {})):
                raise RejectedPlan("Data resource has unknown planned values.")
            continue
        if has_unknown(change.get("after_unknown", {})):
            raise RejectedPlan("Managed resource has unknown planned values.")
        if item.get("address") == address:
            if item.get("type") != "azurerm_virtual_machine_extension":
                raise RejectedPlan("Selected resource is not a VM extension.")
            selected.append(change)
        elif change.get("actions") != ["no-op"]:
            raise RejectedPlan("Plan changes a managed resource outside the selected extension.")
    if len(selected) != 1:
        raise RejectedPlan("Plan must contain exactly one selected extension.")
    change = selected[0]
    if change.get("actions") not in (["update"], ["no-op"]):
        raise RejectedPlan("Selected extension must be an in-place update or no-op.")
    before, after = change.get("before"), change.get("after")
    if not isinstance(before, dict) or not isinstance(after, dict):
        raise RejectedPlan("Selected extension lacks complete before/after values.")
    expected_vm = virtual_machine_id(host)
    if after.get("name") != "Dynatrace" or not isinstance(after.get("virtual_machine_id"), str):
        raise RejectedPlan("Selected extension does not identify the approved VM extension.")
    if after["virtual_machine_id"].lower() != expected_vm.lower():
        raise RejectedPlan("Selected extension belongs to an unexpected VM, resource group or subscription.")
    expected_extension = expected_vm + "/extensions/Dynatrace"
    if not isinstance(after.get("id"), str) or after["id"].lower() != expected_extension.lower():
        raise RejectedPlan("Selected extension resource ID differs from the approved target.")
    different = {
        key for key in before.keys() | after.keys()
        if key not in before or key not in after or before[key] != after[key]
    }
    if different - {"settings"}:
        raise RejectedPlan("Selected extension changes attributes other than settings.")
    old_settings, new_settings = settings(before.get("settings")), settings(after.get("settings"))
    changed_settings = {
        key for key in old_settings.keys() | new_settings.keys()
        if key not in old_settings or key not in new_settings or old_settings[key] != new_settings[key]
    }
    if changed_settings - {"token"}:
        raise RejectedPlan("Selected extension changes settings other than token.")
    if change["actions"] == ["update"] and changed_settings != {"token"}:
        raise RejectedPlan("Selected extension update is not a token change.")
    if change["actions"] == ["no-op"] and (different or changed_settings):
        raise RejectedPlan("No-op extension contains changed values.")
    expected_settings = {
        "tenantId": TENANT_ID,
        "server": "https://dynatrace-activegate-nonprod.platform.hmcts.net:9999/e/yrk32651/api",
        "hostGroup": "Platform_Operation_Bastions",
        "installerArguments": "--set-network-zone=azure.cft",
    }
    if any(new_settings.get(key) != value for key, value in expected_settings.items()):
        raise RejectedPlan("Extension does not match the expected nonprod Dynatrace configuration.")
    token = new_settings.get("token")
    if not isinstance(token, str) or not token.strip() or "\r" in token or "\n" in token:
        raise RejectedPlan("Planned installer token is missing or malformed.")
    sources = list(resources(plan.get("planned_values", {}).get("root_module", {})))
    sources.extend(
        dict(item, values=item.get("change", {}).get("after") or {})
        for item in plan.get("resource_changes", []) if item.get("mode") == "data"
    )
    source_address = f"module.{host}.data.azurerm_key_vault_secret.token"
    selected_sources = [item for item in sources if item.get("address") == source_address]
    if not selected_sources:
        raise RejectedPlan("The selected host's Key Vault token data source is missing.")
    for item in selected_sources:
        values = item.get("values", {})
        if item.get("mode") != "data" or item.get("type") != "azurerm_key_vault_secret" or values.get("name") != SECRET_NAME:
            raise RejectedPlan("The selected token source is not the approved Key Vault secret.")
        version = values.get("version")
        identifier = values.get("id")
        if version != SECRET_VERSION:
            raise RejectedPlan("Planned Key Vault secret version differs from the approved version.")
        expected_id = f"https://infra-vault-nonprod.vault.azure.net/secrets/{SECRET_NAME}/{SECRET_VERSION}"
        if not isinstance(identifier, str) or identifier.lower() != expected_id.lower():
            raise RejectedPlan("Planned Key Vault secret ID differs from the approved source.")
        if values.get("value") != token:
            raise RejectedPlan("Extension token does not match the planned Key Vault source.")
    return token, change["actions"] == ["no-op"]


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def validate_token(token):
    opener = urllib.request.build_opener(
        urllib.request.HTTPSHandler(context=ssl.create_default_context()), NoRedirect()
    )
    request = urllib.request.Request(
        METADATA_URL, headers={"Authorization": "Api-Token " + token, "Accept": "application/json"}
    )
    try:
        with opener.open(request, timeout=30) as response:
            code = response.status
            payload = response.read(65537)
    except urllib.error.HTTPError as error:
        print(f"Installer metadata HTTP status: {error.code}")
        raise RejectedPlan("Installer token validation did not return HTTP 200.") from None
    except Exception:
        raise RejectedPlan("Installer token validation could not complete securely.") from None
    print(f"Installer metadata HTTP status: {code}")
    if code != 200 or len(payload) > 65536:
        raise RejectedPlan("Installer metadata response is not an accepted HTTP 200 response.")
    try:
        version = json.loads(payload).get("latestAgentVersion")
    except (ValueError, AttributeError):
        raise RejectedPlan("Installer metadata response is invalid.") from None
    if not isinstance(version, str) or not re.fullmatch(r"[0-9][0-9A-Za-z_.-]{0,99}", version):
        raise RejectedPlan("Installer metadata version is invalid.")
    print(f"Latest OneAgent version: {version}")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--maintenance-host", required=True, choices=HOSTS)
    args = parser.parse_args(argv)
    try:
        plan = json.load(sys.stdin)
        token, unchanged = validate_plan(plan, args.maintenance_host)
        validate_token(token)
    except RejectedPlan as error:
        print(f"Maintenance validation failed: {error}", file=sys.stderr)
        return 1
    except Exception:
        print("Maintenance validation failed: malformed plan input.", file=sys.stderr)
        return 1
    print("Plan scope accepted: selected extension already reconciled." if unchanged else "Plan scope accepted: one extension token update only.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
