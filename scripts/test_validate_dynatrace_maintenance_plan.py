import contextlib
import copy
import io
import json
from pathlib import Path
import tempfile
import unittest
import urllib.error
from unittest import mock

import validate_dynatrace_maintenance_plan as guard


TOKEN = "TEST_TOKEN_SENTINEL_DO_NOT_PRINT"
AGENT_VERSION = "1.349.109.20261102-164952"


def valid_plan(host="bastion-sbox"):
    new_settings = {
        "tenantId": guard.TENANT_ID,
        "server": "https://dynatrace-activegate-nonprod.platform.hmcts.net:9999/e/yrk32651/api",
        "hostGroup": "Platform_Operation_Bastions",
        "installerArguments": "--set-network-zone=azure.cft",
        "token": TOKEN,
    }
    before = {
        "name": "Dynatrace", "virtual_machine_id": guard.virtual_machine_id(host),
        "id": guard.virtual_machine_id(host) + "/extensions/Dynatrace",
        "settings": json.dumps(dict(new_settings, token="OLD_TEST_TOKEN")),
    }
    after = dict(before, settings=json.dumps(new_settings))
    return {
        "terraform_version": "1.5.6",
        "resource_changes": [{
            "address": guard.target_address(host),
            "mode": "managed",
            "type": "azurerm_virtual_machine_extension",
            "change": {"actions": ["update"], "before": before, "after": after, "after_unknown": {}},
        }],
        "planned_values": {"root_module": {"child_modules": [{"resources": [{
            "address": f"module.{host}.data.azurerm_key_vault_secret.token",
            "mode": "data", "type": "azurerm_key_vault_secret",
            "values": {
                "name": guard.SECRET_NAME, "value": TOKEN, "version": guard.SECRET_VERSION,
                "id": f"https://infra-vault-nonprod.vault.azure.net/secrets/{guard.SECRET_NAME}/{guard.SECRET_VERSION}",
            },
        }]}]}},
    }


class PlanGuardTests(unittest.TestCase):
    def test_all_three_hosts_accept_only_their_target(self):
        for host in guard.HOSTS:
            with self.subTest(host=host):
                self.assertEqual(guard.validate_plan(valid_plan(host), host), (TOKEN, False))

    def test_noop_is_already_resolved(self):
        plan = valid_plan()
        change = plan["resource_changes"][0]["change"]
        change["actions"] = ["no-op"]
        change["before"] = copy.deepcopy(change["after"])
        self.assertEqual(guard.validate_plan(plan, "bastion-sbox"), (TOKEN, True))

    def test_rejects_create_destroy_or_replace(self):
        for actions in (["create"], ["delete"], ["delete", "create"]):
            with self.subTest(actions=actions):
                plan = valid_plan()
                plan["resource_changes"][0]["change"]["actions"] = actions
                with self.assertRaises(guard.RejectedPlan):
                    guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_other_managed_change(self):
        plan = valid_plan()
        extra = copy.deepcopy(plan["resource_changes"][0])
        extra["address"] = "module.other.azurerm_linux_virtual_machine.vm"
        plan["resource_changes"].append(extra)
        with self.assertRaises(guard.RejectedPlan):
            guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_wrong_host(self):
        with self.assertRaises(guard.RejectedPlan):
            guard.validate_plan(valid_plan("bastion-nonprod"), "bastion-sbox")

    def test_rejects_other_top_level_attribute(self):
        plan = valid_plan()
        plan["resource_changes"][0]["change"]["after"]["type_handler_version"] = "9.999"
        with self.assertRaises(guard.RejectedPlan):
            guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_non_token_settings(self):
        for key in ("tenantId", "server", "hostGroup", "installerArguments"):
            with self.subTest(key=key):
                plan = valid_plan()
                after = plan["resource_changes"][0]["change"]["after"]
                configuration = json.loads(after["settings"])
                configuration[key] = "unexpected"
                after["settings"] = json.dumps(configuration)
                with self.assertRaises(guard.RejectedPlan):
                    guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_unknowns(self):
        for mode in ("managed", "data"):
            with self.subTest(mode=mode):
                plan = valid_plan()
                if mode == "managed":
                    plan["resource_changes"][0]["change"]["after_unknown"] = {"settings": True}
                else:
                    plan["resource_changes"].append({"mode": "data", "change": {"actions": ["read"], "after_unknown": {"value": True}}})
                with self.assertRaises(guard.RejectedPlan):
                    guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_source_version_id_or_value_mismatch(self):
        for field in ("version", "id", "value"):
            with self.subTest(field=field):
                plan = valid_plan()
                source = plan["planned_values"]["root_module"]["child_modules"][0]["resources"][0]["values"]
                source[field] = "unapproved"
                with self.assertRaises(guard.RejectedPlan):
                    guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_missing_source(self):
        plan = valid_plan()
        del plan["planned_values"]
        with self.assertRaises(guard.RejectedPlan):
            guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_missing_source_identity_or_value(self):
        for field in ("name", "id", "version", "value"):
            with self.subTest(field=field):
                plan = valid_plan()
                source = plan["planned_values"]["root_module"]["child_modules"][0]["resources"][0]["values"]
                del source[field]
                with self.assertRaises(guard.RejectedPlan):
                    guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_other_hosts_secret_data_source(self):
        plan = valid_plan()
        source = plan["planned_values"]["root_module"]["child_modules"][0]["resources"][0]
        source["address"] = "module.bastion-secops-sbox.data.azurerm_key_vault_secret.token"
        with self.assertRaises(guard.RejectedPlan):
            guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_moved_state_with_wrong_vm_identity(self):
        for old, new in (("b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac", "unexpected-subscription"), ("bastion-sbox-rg", "other-rg"), ("virtualMachines/bastion-sbox", "virtualMachines/other-host")):
            with self.subTest(component=old):
                plan = valid_plan()
                for side in ("before", "after"):
                    values = plan["resource_changes"][0]["change"][side]
                    values["virtual_machine_id"] = values["virtual_machine_id"].replace(old, new)
                    values["id"] = values["id"].replace(old, new)
                with self.assertRaises(guard.RejectedPlan):
                    guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_wrong_extension_name_or_id(self):
        for field in ("name", "id"):
            with self.subTest(field=field):
                plan = valid_plan()
                for side in ("before", "after"):
                    plan["resource_changes"][0]["change"][side][field] = "unexpected-extension"
                with self.assertRaises(guard.RejectedPlan):
                    guard.validate_plan(plan, "bastion-sbox")

    def test_checks_source_version_in_data_resource_changes(self):
        plan = valid_plan()
        source = plan.pop("planned_values")["root_module"]["child_modules"][0]["resources"][0]
        source["change"] = {"actions": ["no-op"], "after": source.pop("values")}
        source["change"]["after"]["version"] = "unapproved"
        plan["resource_changes"].append(source)
        with self.assertRaises(guard.RejectedPlan):
            guard.validate_plan(plan, "bastion-sbox")

    def test_accepts_refreshed_data_present_only_in_prior_state(self):
        for host in guard.HOSTS:
            with self.subTest(host=host):
                plan = valid_plan(host)
                plan["prior_state"] = {"values": plan.pop("planned_values")}
                self.assertEqual(guard.validate_plan(plan, host), (TOKEN, False))

    def test_prior_state_still_requires_exact_version_id_and_token(self):
        for field in ("version", "id", "value"):
            with self.subTest(field=field):
                plan = valid_plan()
                plan["prior_state"] = {"values": plan.pop("planned_values")}
                source = plan["prior_state"]["values"]["root_module"]["child_modules"][0]["resources"][0]["values"]
                source[field] = "unapproved"
                with self.assertRaises(guard.RejectedPlan):
                    guard.validate_plan(plan, "bastion-sbox")

    def test_missing_source_diagnostics_print_only_static_presence_counts(self):
        plan = valid_plan()
        plan["prior_state"] = {"values": plan.pop("planned_values")}
        source = plan["prior_state"]["values"]["root_module"]["child_modules"][0]["resources"][0]
        source["address"] = TOKEN
        output = io.StringIO()
        with contextlib.redirect_stdout(output), self.assertRaises(guard.RejectedPlan):
            guard.validate_plan(plan, "bastion-sbox")
        self.assertNotIn(TOKEN, output.getvalue())
        self.assertEqual(output.getvalue(),
                         "Key Vault source presence: planned_values: expected source absent; secret data entries=0.\n"
                         "Key Vault source presence: resource_changes: expected source absent; secret data entries=0.\n"
                         "Key Vault source presence: prior_state: expected source absent; secret data entries=1.\n")

    def test_rejects_duplicate_target(self):
        plan = valid_plan()
        plan["resource_changes"].append(copy.deepcopy(plan["resource_changes"][0]))
        with self.assertRaises(guard.RejectedPlan):
            guard.validate_plan(plan, "bastion-sbox")

    def test_rejects_wrong_terraform_version(self):
        plan = valid_plan()
        plan["terraform_version"] = "unexpected"
        with self.assertRaises(guard.RejectedPlan):
            guard.validate_plan(plan, "bastion-sbox")

    def test_failure_output_never_contains_plan_values(self):
        plan = valid_plan()
        plan["resource_changes"][0]["change"]["after"]["settings"] = TOKEN
        output = io.StringIO()
        with mock.patch.object(guard.sys, "stdin", io.StringIO(json.dumps(plan))), contextlib.redirect_stdout(output), contextlib.redirect_stderr(output):
            result = guard.main(["--maintenance-host", "bastion-sbox"])
        self.assertEqual(result, 1)
        self.assertNotIn(TOKEN, output.getvalue())

    def test_require_noop_rejects_remaining_update_before_token_request(self):
        output = io.StringIO()
        with mock.patch.object(guard.sys, "stdin", io.StringIO(json.dumps(valid_plan()))), mock.patch.object(guard, "validate_token") as token_check, contextlib.redirect_stdout(output), contextlib.redirect_stderr(output):
            result = guard.main(["--maintenance-host", "bastion-sbox", "--require-noop"])
        self.assertEqual(result, 1)
        token_check.assert_not_called()
        self.assertIn("still contains an extension update", output.getvalue())
        self.assertNotIn("Plan scope accepted", output.getvalue())
        self.assertNotIn(TOKEN, output.getvalue())

    def test_require_noop_accepts_reconciled_extension_and_still_checks_token(self):
        plan = valid_plan()
        change = plan["resource_changes"][0]["change"]
        change["actions"] = ["no-op"]
        change["before"] = copy.deepcopy(change["after"])
        output = io.StringIO()
        with mock.patch.object(guard.sys, "stdin", io.StringIO(json.dumps(plan))), mock.patch.object(guard, "validate_token", return_value=AGENT_VERSION) as token_check, contextlib.redirect_stdout(output), contextlib.redirect_stderr(output):
            result = guard.main(["--maintenance-host", "bastion-sbox", "--require-noop"])
        self.assertEqual(result, 0)
        token_check.assert_called_once_with(TOKEN)
        self.assertIn("selected extension already reconciled", output.getvalue())
        self.assertNotIn(TOKEN, output.getvalue())


class InstallerTokenTests(unittest.TestCase):
    def fake_response(self, payload):
        response = mock.MagicMock()
        response.__enter__.return_value = response
        response.status = 200
        response.read.return_value = json.dumps(payload).encode()
        return response

    def test_header_only_verified_tls_request_and_safe_output(self):
        opener = mock.Mock()
        opener.open.return_value = self.fake_response({"latestAgentVersion": "1.349.109.20261102-164952"})
        output = io.StringIO()
        with mock.patch.object(guard.urllib.request, "build_opener", return_value=opener) as builder, contextlib.redirect_stdout(output):
            self.assertEqual(guard.validate_token(TOKEN), AGENT_VERSION)
        handlers = builder.call_args.args
        self.assertEqual(handlers[0]._context.verify_mode, guard.ssl.CERT_REQUIRED)
        self.assertTrue(handlers[0]._context.check_hostname)
        self.assertIsInstance(handlers[1], guard.NoRedirect)
        request = opener.open.call_args.args[0]
        self.assertEqual(request.full_url, guard.METADATA_URL)
        self.assertNotIn(TOKEN, request.full_url)
        self.assertEqual(request.get_header("Authorization"), "Api-Token " + TOKEN)
        self.assertNotIn(TOKEN, output.getvalue())
        self.assertIn("HTTP status: 200", output.getvalue())

    def test_redirects_are_blocked(self):
        self.assertIsNone(guard.NoRedirect().redirect_request(None, None, 302, None, None, "https://other.invalid"))

    def test_http_errors_do_not_print_response_body_or_token(self):
        for code in (302, 401, 403, 500):
            with self.subTest(code=code):
                opener = mock.Mock()
                opener.open.side_effect = urllib.error.HTTPError(guard.METADATA_URL, code, TOKEN, {}, io.BytesIO(TOKEN.encode()))
                output = io.StringIO()
                with mock.patch.object(guard.urllib.request, "build_opener", return_value=opener), contextlib.redirect_stdout(output), self.assertRaises(guard.RejectedPlan):
                    guard.validate_token(TOKEN)
                self.assertEqual(output.getvalue(), f"Installer metadata HTTP status: {code}\n")

    def test_transport_errors_are_redacted(self):
        opener = mock.Mock()
        opener.open.side_effect = urllib.error.URLError(TOKEN)
        with mock.patch.object(guard.urllib.request, "build_opener", return_value=opener):
            with self.assertRaises(guard.RejectedPlan) as error:
                guard.validate_token(TOKEN)
        self.assertNotIn(TOKEN, str(error.exception))

    def test_invalid_metadata_never_prints_secret(self):
        opener = mock.Mock()
        opener.open.return_value = self.fake_response({"latestAgentVersion": TOKEN})
        output = io.StringIO()
        with mock.patch.object(guard.urllib.request, "build_opener", return_value=opener), contextlib.redirect_stdout(output), self.assertRaises(guard.RejectedPlan):
            guard.validate_token(TOKEN)
        self.assertNotIn(TOKEN, output.getvalue())


class GuestVersionGateTests(unittest.TestCase):
    def baseline(self, host="bastion-sbox"):
        return {"maintenance_host": host, "report": {
            "schema": 1, "healthy": True, "oneagent_version": AGENT_VERSION,
        }}

    def run_guard(self, baseline_path=None, metadata_version=AGENT_VERSION, host="bastion-sbox"):
        arguments = ["--maintenance-host", host]
        if baseline_path is not None:
            arguments.extend(["--guest-health-file", str(baseline_path)])
        output = io.StringIO()
        with mock.patch.object(guard.sys, "stdin", io.StringIO(json.dumps(valid_plan(host)))), mock.patch.object(guard, "validate_token", return_value=metadata_version) as token_check, contextlib.redirect_stdout(output), contextlib.redirect_stderr(output):
            result = guard.main(arguments)
        self.assertNotIn(TOKEN, output.getvalue())
        return result, output.getvalue(), token_check

    def test_existing_plan_only_cli_remains_compatible(self):
        result, output, token_check = self.run_guard()
        self.assertEqual(result, 0)
        token_check.assert_called_once_with(TOKEN)
        self.assertNotIn("Guest baseline accepted", output)

    def test_exact_latest_version_passes_for_same_host(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "guest-before.json"
            for host in guard.HOSTS:
                with self.subTest(host=host):
                    path.write_text(json.dumps(self.baseline(host)))
                    result, output, token_check = self.run_guard(path, host=host)
                    self.assertEqual(result, 0)
                    self.assertIn("Guest baseline accepted", output)
                    token_check.assert_called_once_with(TOKEN)

    def test_newer_older_or_shortened_version_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "guest-before.json"
            path.write_text(json.dumps(self.baseline()))
            for version in ("1.350.1.20261120-010000", "1.348.1.20261001-010000", "1.349.109", None):
                with self.subTest(version=version):
                    result, output, _ = self.run_guard(path, metadata_version=version)
                    self.assertEqual(result, 1)
                    self.assertIn("differs from the checked guest", output)
                    self.assertNotIn("Plan scope accepted", output)

    def test_missing_malformed_oversized_or_unhealthy_baseline_rejected_before_token_request(self):
        bad = [TOKEN, "x" * 4097, "[]", json.dumps(self.baseline("bastion-nonprod"))]
        for field, value in (("schema", True), ("schema", 2), ("healthy", False), ("healthy", "true"), ("oneagent_version", TOKEN), ("oneagent_version", None)):
            baseline = self.baseline()
            baseline["report"][field] = value
            bad.append(json.dumps(baseline))
        for field in ("maintenance_host", "report"):
            baseline = self.baseline()
            del baseline[field]
            bad.append(json.dumps(baseline))
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "guest-before.json"
            result, _, token_check = self.run_guard(path)
            self.assertEqual(result, 1)
            token_check.assert_not_called()
            for index, contents in enumerate(bad):
                with self.subTest(case=index):
                    path.write_text(contents)
                    result, output, token_check = self.run_guard(path)
                    self.assertEqual(result, 1)
                    self.assertNotIn("Plan scope accepted", output)
                    token_check.assert_not_called()


class PipelineSecretRegistrationTests(unittest.TestCase):
    def run_guard(self, plan, flag=True, environment="true"):
        arguments = ["--maintenance-host", "bastion-sbox"]
        if flag:
            arguments.append("--register-pipeline-secrets")
        output = io.StringIO()
        with mock.patch.object(guard.sys, "stdin", io.StringIO(json.dumps(plan))), mock.patch.dict(guard.os.environ, {"TF_BUILD": environment}), mock.patch.object(guard, "validate_token", return_value=AGENT_VERSION) as token_check, contextlib.redirect_stdout(output), contextlib.redirect_stderr(output):
            result = guard.main(arguments)
        return result, output.getvalue(), token_check

    def test_explicit_pipeline_flag_registers_exact_old_and_new_tokens(self):
        result, output, token_check = self.run_guard(valid_plan(), environment="TrUe")
        self.assertEqual(result, 0)
        self.assertEqual([line for line in output.splitlines() if line.startswith("##vso[")], [
            "##vso[task.setsecret]OLD_TEST_TOKEN", "##vso[task.setsecret]" + TOKEN,
        ])
        self.assertEqual(output.count(TOKEN), 1)
        self.assertEqual(output.count("OLD_TEST_TOKEN"), 1)
        token_check.assert_called_once_with(TOKEN)

    def test_default_does_not_register_or_expose_tokens(self):
        result, output, _ = self.run_guard(valid_plan(), flag=False)
        self.assertEqual(result, 0)
        self.assertNotIn("##vso[", output)
        self.assertNotIn(TOKEN, output)
        self.assertNotIn("OLD_TEST_TOKEN", output)

    def test_non_pipeline_context_fails_before_token_output_or_http(self):
        for environment in ("", "false", "1"):
            with self.subTest(environment=environment):
                result, output, token_check = self.run_guard(valid_plan(), environment=environment)
                self.assertEqual(result, 1)
                self.assertNotIn("##vso[", output)
                self.assertNotIn(TOKEN, output)
                self.assertNotIn("OLD_TEST_TOKEN", output)
                token_check.assert_not_called()

    def test_structurally_invalid_or_wrong_host_plan_never_registers(self):
        wrong_scope = valid_plan()
        wrong_scope["resource_changes"][0]["change"]["after"]["name"] = "unexpected"
        for plan in (wrong_scope, valid_plan("bastion-nonprod")):
            result, output, token_check = self.run_guard(plan)
            self.assertEqual(result, 1)
            self.assertNotIn("##vso[", output)
            self.assertNotIn(TOKEN, output)
            token_check.assert_not_called()

    def test_logging_command_escapes_percent_cr_and_lf(self):
        plan = valid_plan()
        change = plan["resource_changes"][0]["change"]
        old_settings = json.loads(change["before"]["settings"])
        old_settings["token"] = "OLD%TOKEN\r\n##vso[task.complete]Injected"
        change["before"]["settings"] = json.dumps(old_settings)
        result, output, _ = self.run_guard(plan)
        self.assertEqual(result, 0)
        commands = [line for line in output.splitlines() if line.startswith("##vso[")]
        self.assertEqual(commands, [
            "##vso[task.setsecret]OLD%AZP25TOKEN%0D%0A##vso[task.complete]Injected",
            "##vso[task.setsecret]" + TOKEN,
        ])
        self.assertNotIn("\n##vso[task.complete]", output)

    def test_unusable_old_token_fails_without_partial_registration(self):
        plan = valid_plan()
        change = plan["resource_changes"][0]["change"]
        old_settings = json.loads(change["before"]["settings"])
        old_settings["token"] = None
        change["before"]["settings"] = json.dumps(old_settings)
        result, output, token_check = self.run_guard(plan)
        self.assertEqual(result, 1)
        self.assertNotIn("##vso[", output)
        self.assertNotIn(TOKEN, output)
        token_check.assert_not_called()


if __name__ == "__main__":
    unittest.main()
