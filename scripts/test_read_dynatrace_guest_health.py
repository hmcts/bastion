import contextlib
import copy
import io
import json
from pathlib import Path
import tempfile
import types
import unittest
from unittest import mock

import read_dynatrace_guest_health as health


BOOT_ID = "33333333-4444-5555-6666-777777777777"
SECRET = "TEST_SENTINEL_MUST_NOT_BE_PRINTED"


def report():
    return {
        "schema": 1, "healthy": True,
        "oneagent_service": {"load": "loaded", "active": "active", "sub": "running"},
        "ssh_service": {"load": "loaded", "active": "inactive", "sub": "dead"},
        "ssh_socket": {"load": "loaded", "active": "active", "sub": "listening"},
        "port22_listening": True, "boot_id": BOOT_ID,
        "oneagent_version": "1.349.109.20261102-164952", "auto_update_enabled": True,
    }


def response(value=None):
    value = report() if value is None else value
    message = "Enable succeeded:\n[stdout]\n" + health.PREFIX + json.dumps(value) + "\n[stderr]\n"
    return {"value": [{"code": "ProvisioningState/succeeded", "message": message}]}


class ResponseTests(unittest.TestCase):
    def test_accepts_ssh_socket_activation(self):
        self.assertEqual(health.parse_run_command(response()), report())

    def test_accepts_running_ssh_service_without_socket(self):
        value = report()
        value["ssh_service"] = {"load": "loaded", "active": "active", "sub": "running"}
        value["ssh_socket"] = {"load": "not-found", "active": "inactive", "sub": "dead"}
        self.assertEqual(health.parse_run_command(response(value)), value)

    def test_rejects_empty_failed_malformed_and_oversized_results(self):
        bad = [
            {}, {"value": []}, {"value": [{"code": "ProvisioningState/failed", "message": SECRET}]},
            {"value": [{"code": "ProvisioningState/succeeded", "message": SECRET}]},
            {"value": [{"code": "ProvisioningState/succeeded", "message": health.PREFIX + "bad-json"}]},
            {"value": [{"code": "ProvisioningState/succeeded", "message": "x" * 4097}]},
        ]
        duplicate = response()
        duplicate["value"].append(copy.deepcopy(duplicate["value"][0]))
        bad.append(duplicate)
        for item in bad:
            with self.subTest(case=bad.index(item)), self.assertRaises(health.HealthCheckFailed) as error:
                health.parse_run_command(item)
            self.assertNotIn(SECRET, str(error.exception))

    def test_rejects_unhealthy_or_untrusted_report_fields(self):
        for field, bad_value in (
            ("schema", True),
            ("healthy", False), ("port22_listening", False), ("boot_id", SECRET),
            ("oneagent_version", SECRET), ("auto_update_enabled", SECRET),
            ("oneagent_service", {"load": "loaded", "active": "failed", "sub": "failed"}),
            ("ssh_socket", {"load": "loaded", "active": "inactive", "sub": "dead"}),
        ):
            value = report()
            value[field] = bad_value
            with self.subTest(field=field), self.assertRaises(health.HealthCheckFailed):
                health.parse_run_command(response(value))
        value = report()
        value["token"] = SECRET
        with self.assertRaises(health.HealthCheckFailed):
            health.parse_run_command(response(value))

    def test_each_host_uses_exact_immutable_scope(self):
        for host in health.HOSTS:
            output = io.StringIO()
            vm = {"power": ["PowerState/running"], "provisioning": ["ProvisioningState/succeeded"]}
            with self.subTest(host=host), mock.patch.object(health, "azure_json", side_effect=[vm, response()]) as az, contextlib.redirect_stdout(output):
                health.check_host(host)
            subscription, group = health.HOST_RESOURCES[host]
            for call in az.call_args_list:
                args = call.args[0]
                self.assertEqual(args[args.index("--subscription") + 1], subscription)
                self.assertEqual(args[args.index("--resource-group") + 1], group)
                self.assertEqual(args[args.index("--name") + 1], host)
            self.assertLess(len(output.getvalue().encode()), 4096)

    def test_stopped_vm_prevents_guest_command(self):
        with mock.patch.object(health, "azure_json", return_value={"power": ["PowerState/deallocated"], "provisioning": ["ProvisioningState/succeeded"]}) as az:
            with self.assertRaises(health.HealthCheckFailed):
                health.check_host("bastion-sbox")
        self.assertEqual(az.call_count, 1)

    def test_azure_failure_does_not_expose_output(self):
        result = types.SimpleNamespace(returncode=1, stdout=SECRET, stderr=SECRET)
        output = io.StringIO()
        with mock.patch.object(health.subprocess, "run", return_value=result), contextlib.redirect_stdout(output), contextlib.redirect_stderr(output):
            code = health.main(["--maintenance-host", "bastion-sbox"])
        self.assertEqual(code, 1)
        self.assertNotIn(SECRET, output.getvalue())


class BaselineTests(unittest.TestCase):
    def test_saved_report_is_private_and_host_bound(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "guest-before.json"
            health.save_report(path, "bastion-sbox", report())
            self.assertEqual(path.stat().st_mode & 0o777, 0o600)
            self.assertLess(path.stat().st_size, 4096)
            self.assertEqual(health.read_baseline(path, "bastion-sbox"), report())
            with self.assertRaises(health.HealthCheckFailed):
                health.read_baseline(path, "bastion-nonprod")

    def test_invalid_baseline_rejected_without_exposing_input(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "baseline.json"
            for contents in (SECRET, "x" * 4097, json.dumps({"maintenance_host": "bastion-sbox", "report": report(), "token": SECRET})):
                path.write_text(contents)
                with self.assertRaises(health.HealthCheckFailed) as error:
                    health.read_baseline(path, "bastion-sbox")
                self.assertNotIn(SECRET, str(error.exception))

    def test_baseline_rejects_reboot_and_version_change(self):
        health.compare_baseline(report(), report())
        for key, value in (("boot_id", "44444444-4444-5555-6666-777777777777"), ("oneagent_version", "1.350.1")):
            current = report()
            current[key] = value
            with self.subTest(field=key), self.assertRaises(health.HealthCheckFailed):
                health.compare_baseline(current, report())

    def test_file_symlink_is_not_followed(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "target"
            target.write_text("unchanged")
            link = Path(directory) / "report"
            link.symlink_to(target)
            with self.assertRaises(health.HealthCheckFailed):
                health.save_report(link, "bastion-sbox", report())
            self.assertEqual(target.read_text(), "unchanged")

    def test_cli_checks_baseline_before_saving_post_report(self):
        with tempfile.TemporaryDirectory() as directory:
            before = Path(directory) / "before.json"
            after = Path(directory) / "after.json"
            health.save_report(before, "bastion-sbox", report())
            arguments = ["--maintenance-host", "bastion-sbox", "--baseline-file", str(before), "--report-file", str(after)]
            with mock.patch.object(health, "check_host", return_value=report()), contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(health.main(arguments), 0)
            self.assertEqual(health.read_baseline(after, "bastion-sbox"), report())
            after.unlink()
            changed = report()
            changed["oneagent_version"] = "1.350.1"
            with mock.patch.object(health, "check_host", return_value=changed), contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(health.main(arguments), 1)
            self.assertFalse(after.exists())


class GuestScriptTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        script = Path(__file__).with_name("check_dynatrace_guest_health.sh").read_text()
        code = script.split("python3 - <<'PY'\n", 1)[1].rsplit("\nPY", 1)[0]
        cls.guest = {"__name__": "read_only_guest_test"}
        exec(compile(code, "check_dynatrace_guest_health.sh", "exec"), cls.guest)

    def command_output(self, arguments):
        if arguments[:2] == ["systemctl", "show"]:
            unit = arguments[2]
            states = {
                "oneagent.service": "LoadState=loaded\nActiveState=active\nSubState=running",
                "ssh.service": "LoadState=loaded\nActiveState=inactive\nSubState=dead",
                "ssh.socket": "LoadState=loaded\nActiveState=active\nSubState=listening",
            }
            return states[unit]
        if arguments == ["ss", "-H", "-ltn", "( sport = :22 )"]:
            return "LISTEN 0 4096 0.0.0.0:22 0.0.0.0:*"
        if arguments == [self.guest["CTL"], "--version"]:
            return "1.349.109.20261102-164952"
        if arguments == [self.guest["CTL"], "--get-auto-update-enabled"]:
            return "true"
        self.fail("Guest script requested a command outside the read-only allowlist")

    def test_guest_command_allowlist_and_bounded_sentinel(self):
        output = io.StringIO()
        with mock.patch.dict(self.guest, {"read_command": self.command_output}), mock.patch.object(Path, "read_text", return_value=BOOT_ID), contextlib.redirect_stdout(output):
            code = self.guest["main"]()
        self.assertEqual(code, 0)
        line = output.getvalue().strip()
        self.assertTrue(line.startswith(health.PREFIX))
        self.assertLess(len(line.encode()), 4096)
        self.assertEqual(health.validate_report(json.loads(line[len(health.PREFIX):])), report())

    def test_inactive_agent_reports_failure(self):
        def output(arguments):
            if arguments[:3] == ["systemctl", "show", "oneagent.service"]:
                return "LoadState=loaded\nActiveState=inactive\nSubState=dead"
            return self.command_output(arguments)
        with mock.patch.dict(self.guest, {"read_command": output}), mock.patch.object(Path, "read_text", return_value=BOOT_ID):
            self.assertFalse(self.guest["collect"]()["healthy"])

    def test_unexpected_command_failure_is_redacted(self):
        output = io.StringIO()
        with mock.patch.dict(self.guest, {"read_command": mock.Mock(side_effect=RuntimeError(SECRET))}), contextlib.redirect_stdout(output):
            code = self.guest["main"]()
        self.assertEqual(code, 1)
        self.assertNotIn(SECRET, output.getvalue())
        self.assertIn('"healthy":false', output.getvalue())


if __name__ == "__main__":
    unittest.main()
