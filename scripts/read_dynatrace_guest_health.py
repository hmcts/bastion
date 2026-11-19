"""Run a bounded read-only guest check against one fixed maintenance VM."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import uuid

from validate_dynatrace_maintenance_plan import HOST_RESOURCES, HOSTS


PREFIX = "DYNATRACE_GUEST_HEALTH_V1 "
VERSION = r"1\.\d+\.\d+(?:\.\d{8}-\d{6})?"
STATES = {
    "load": {"loaded", "not-found", "masked", "error"},
    "active": {"active", "inactive", "failed", "activating", "deactivating", "reloading", "unknown"},
    "sub": {"running", "exited", "listening", "dead", "failed", "start", "stop", "auto-restart", "unknown"},
}


class HealthCheckFailed(Exception):
    pass


def azure_json(arguments):
    try:
        result = subprocess.run(
            ["az", *arguments, "--only-show-errors", "--output", "json"],
            capture_output=True, text=True, timeout=600, check=False,
        )
        if result.returncode != 0 or not result.stdout or len(result.stdout) > 16384:
            raise HealthCheckFailed("Azure read-only health request failed.")
        return json.loads(result.stdout)
    except HealthCheckFailed:
        raise
    except Exception:
        raise HealthCheckFailed("Azure read-only health response was unavailable or malformed.") from None


def validate_report(report):
    fields = {
        "schema", "healthy", "oneagent_service", "ssh_service", "ssh_socket",
        "port22_listening", "boot_id", "oneagent_version", "auto_update_enabled",
    }
    if not isinstance(report, dict) or set(report) != fields or type(report["schema"]) is not int or report["schema"] != 1:
        raise HealthCheckFailed("Guest health report has an unexpected schema.")
    for field in ("oneagent_service", "ssh_service", "ssh_socket"):
        state = report[field]
        if not isinstance(state, dict) or set(state) != set(STATES):
            raise HealthCheckFailed("Guest service status is malformed.")
        if any(not isinstance(state[key], str) or state[key] not in allowed for key, allowed in STATES.items()):
            raise HealthCheckFailed("Guest service status is unexpected.")
    if report["healthy"] is not True or report["port22_listening"] is not True:
        raise HealthCheckFailed("Guest health check did not pass.")
    if not isinstance(report["auto_update_enabled"], bool):
        raise HealthCheckFailed("OneAgent auto-update status is unavailable.")
    version = report["oneagent_version"]
    if not isinstance(version, str) or not re.fullmatch(VERSION, version):
        raise HealthCheckFailed("OneAgent version is unavailable or malformed.")
    try:
        if str(uuid.UUID(report["boot_id"])) != report["boot_id"]:
            raise ValueError
    except Exception:
        raise HealthCheckFailed("Guest boot identifier is malformed.") from None
    agent = report["oneagent_service"]
    if agent["load"] != "loaded" or agent["active"] != "active" or agent["sub"] not in {"running", "exited"}:
        raise HealthCheckFailed("OneAgent service is not active.")
    if not (
        report["ssh_service"] == {"load": "loaded", "active": "active", "sub": "running"}
        or report["ssh_socket"] == {"load": "loaded", "active": "active", "sub": "listening"}
    ):
        raise HealthCheckFailed("Neither SSH service nor SSH socket is ready.")
    return report


def read_baseline(path, host):
    try:
        with Path(path).open() as stream:
            raw = stream.read(4097)
        if len(raw.encode("utf-8")) > 4096:
            raise ValueError
        saved = json.loads(raw)
        if not isinstance(saved, dict) or set(saved) != {"maintenance_host", "report"} or saved["maintenance_host"] != host:
            raise ValueError
        return validate_report(saved["report"])
    except Exception:
        raise HealthCheckFailed("Guest health baseline is unavailable, malformed, or belongs to another host.") from None


def compare_baseline(report, baseline):
    if report["boot_id"] != baseline["boot_id"]:
        raise HealthCheckFailed("Guest boot identifier changed from the baseline.")
    if report["oneagent_version"] != baseline["oneagent_version"]:
        raise HealthCheckFailed("OneAgent version changed from the baseline.")


def save_report(path, host, report):
    payload = json.dumps({"maintenance_host": host, "report": validate_report(report)}, separators=(",", ":"), sort_keys=True)
    try:
        descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_TRUNC | os.O_NOFOLLOW, 0o600)
        with os.fdopen(descriptor, "w") as stream:
            os.fchmod(stream.fileno(), 0o600)
            stream.write(payload + "\n")
    except Exception:
        raise HealthCheckFailed("Guest health report could not be saved privately.") from None


def parse_run_command(response):
    if not isinstance(response, dict) or not isinstance(response.get("value"), list) or not response["value"]:
        raise HealthCheckFailed("Guest command returned no status records.")
    messages = []
    success_codes = {"ProvisioningState/succeeded", "ComponentStatus/StdOut/succeeded", "ComponentStatus/StdErr/succeeded"}
    for record in response["value"]:
        if not isinstance(record, dict) or record.get("code") not in success_codes or not isinstance(record.get("message"), str):
            raise HealthCheckFailed("Guest command status failed or was malformed.")
        messages.append(record["message"])
    output = "\n".join(messages)
    if len(output.encode("utf-8")) > 4096:
        raise HealthCheckFailed("Guest command output exceeded the safe output bound.")
    payloads = [line[len(PREFIX):] for line in output.splitlines() if line.startswith(PREFIX)]
    if len(payloads) != 1:
        raise HealthCheckFailed("Guest command did not return exactly one health sentinel.")
    try:
        report = json.loads(payloads[0])
    except Exception:
        raise HealthCheckFailed("Guest health sentinel was malformed.") from None
    return validate_report(report)


def check_host(host):
    subscription, resource_group = HOST_RESOURCES[host]
    scope = ["--subscription", subscription, "--resource-group", resource_group]
    view = azure_json([
        "vm", "get-instance-view", *scope, "--name", host, "--query",
        "{power:instanceView.statuses[?starts_with(code, 'PowerState/')].code,provisioning:instanceView.statuses[?starts_with(code, 'ProvisioningState/')].code}",
    ])
    if view != {"power": ["PowerState/running"], "provisioning": ["ProvisioningState/succeeded"]}:
        raise HealthCheckFailed("Selected VM is not running with successful provisioning.")
    script = Path(__file__).with_name("check_dynatrace_guest_health.sh").resolve()
    response = azure_json([
        "vm", "run-command", "invoke", *scope, "--name", host,
        "--command-id", "RunShellScript", "--scripts", "@" + str(script),
        "--query", "{value:value[].{code:code,message:message}}",
    ])
    report = parse_run_command(response)
    print(f"VM health: {host}: running; provisioning succeeded.")
    print(PREFIX + json.dumps(report, separators=(",", ":"), sort_keys=True))
    return report


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--maintenance-host", choices=HOSTS, required=True)
    parser.add_argument("--report-file", help="Save a validated, safe health report in the private agent directory.")
    parser.add_argument("--baseline-file", help="Require the same host, boot ID, and OneAgent version as this saved report.")
    args = parser.parse_args(argv)
    try:
        baseline = read_baseline(args.baseline_file, args.maintenance_host) if args.baseline_file else None
        report = check_host(args.maintenance_host)
        if baseline is not None:
            compare_baseline(report, baseline)
            print("Guest health baseline: boot identifier and OneAgent version unchanged.")
        if args.report_file:
            save_report(args.report_file, args.maintenance_host, report)
    except HealthCheckFailed as error:
        print(f"Guest health check failed: {error}", file=sys.stderr)
        return 1
    except Exception:
        print("Guest health check failed: unexpected response.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
