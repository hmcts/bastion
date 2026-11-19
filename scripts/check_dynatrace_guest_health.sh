#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import json
from pathlib import Path
import re
import subprocess
import sys
import uuid

PREFIX = "DYNATRACE_GUEST_HEALTH_V1 "
CTL = "/opt/dynatrace/oneagent/agent/tools/oneagentctl"
VERSION = r"1\.\d+\.\d+(?:\.\d{8}-\d{6})?"
STATES = {
    "load": {"loaded", "not-found", "masked", "error"},
    "active": {"active", "inactive", "failed", "activating", "deactivating", "reloading", "unknown"},
    "sub": {"running", "exited", "listening", "dead", "failed", "start", "stop", "auto-restart", "unknown"},
}


def read_command(arguments):
    result = subprocess.run(arguments, capture_output=True, text=True, timeout=15, check=False)
    if result.returncode != 0 or len(result.stdout) > 4096:
        return None
    return result.stdout.strip()


def service(unit):
    output = read_command([
        "systemctl", "show", unit,
        "--property=LoadState,ActiveState,SubState", "--no-pager",
    ])
    properties = dict(line.split("=", 1) for line in (output or "").splitlines() if "=" in line)
    result = {}
    for key, property_name in (("load", "LoadState"), ("active", "ActiveState"), ("sub", "SubState")):
        value = properties.get(property_name)
        result[key] = value if value in STATES[key] else ("error" if key == "load" else "unknown")
    return result


def collect():
    oneagent = service("oneagent.service")
    ssh = service("ssh.service")
    socket = service("ssh.socket")
    listeners = read_command(["ss", "-H", "-ltn", "( sport = :22 )"])
    version_output = read_command([CTL, "--version"])
    version_matches = re.findall(r"(?<![\w.])(" + VERSION + r")(?![\w.-])", version_output or "")
    version = version_matches[0] if len(version_matches) == 1 else None
    update_output = read_command([CTL, "--get-auto-update-enabled"])
    auto_update = {"true": True, "false": False}.get((update_output or "").lower())
    boot_id = str(uuid.UUID(Path("/proc/sys/kernel/random/boot_id").read_text().strip()))
    port22 = bool(listeners)
    ssh_ready = (
        ssh == {"load": "loaded", "active": "active", "sub": "running"}
        or socket == {"load": "loaded", "active": "active", "sub": "listening"}
    )
    healthy = (
        oneagent["load"] == "loaded" and oneagent["active"] == "active"
        and oneagent["sub"] in {"running", "exited"}
        and ssh_ready and port22 and version is not None and auto_update is not None
    )
    return {
        "schema": 1, "healthy": healthy,
        "oneagent_service": oneagent, "ssh_service": ssh, "ssh_socket": socket,
        "port22_listening": port22, "boot_id": boot_id,
        "oneagent_version": version, "auto_update_enabled": auto_update,
    }


def main():
    try:
        report = collect()
    except Exception:
        report = {"schema": 1, "healthy": False, "error": "read_only_check_failed"}
    print(PREFIX + json.dumps(report, separators=(",", ":"), sort_keys=True))
    return 0 if report["healthy"] else 1


if __name__ == "__main__":
    sys.exit(main())
PY
