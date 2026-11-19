import json
import subprocess
import sys
import tempfile
from pathlib import Path

vaults = {
    "sbox": ("b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac", "bastion-sbox-rg", "bastion-sbox-hmcts-kv", "083265d1-2e54-40ef-83bc-34fd5a1f1bcf"),
    "nonprod": ("b44eb479-9ae2-42e7-9c63-f3c599719b6f", "bastion-nonprod-rg", "bastion-nonprod-kv", "65326fe1-e4fe-444a-becb-d7f6a53091df"),
    "prod": ("2b1afc19-5ca9-4796-a56f-574a58670244", "bastion-prod-rg", "bastion-prod-hmcts-kv", "5d16e46d-017b-4ae0-859c-22a10cce59e9"),
}
subscription, group, name, principal = vaults[sys.argv[1]]
url = f"https://management.azure.com/subscriptions/{subscription}/resourceGroups/{group}/providers/Microsoft.KeyVault/vaults/{name}"

def read_vault():
    return json.loads(subprocess.check_output(["az", "rest", "--method", "get", "--url", url + "?api-version=2023-07-01", "-o", "json"], text=True))["properties"]

def policies(properties):
    return {p["objectId"]: p for p in properties["accessPolicies"]}

before = read_vault()
assert not before.get("enableRbacAuthorization", False), "Unexpected RBAC vault"
existing = policies(before)
required = {"get", "list", "set", "delete"}
if principal in existing:
    assert set(existing[principal]["permissions"].get("secrets", [])) == required, "Unexpected existing WIF permissions"
    print(f"{name}: WIF policy already present")
else:
    body = {"properties": {"accessPolicies": [{"tenantId": before["tenantId"], "objectId": principal, "permissions": {"secrets": sorted(required)}}]}}
    with tempfile.TemporaryDirectory() as directory:
        path = Path(directory) / "policy.json"
        path.write_text(json.dumps(body))
        subprocess.run(["az", "rest", "--method", "put", "--url", url + "/accessPolicies/add?api-version=2023-07-01", "--body", "@" + str(path), "-o", "none"], check=True)
    print(f"{name}: added WIF secret Get/List/Set/Delete policy")
after = read_vault()
updated = policies(after)
assert set(updated[principal]["permissions"].get("secrets", [])) == required
for key, policy in existing.items():
    assert updated[key] == policy, f"Existing policy changed: {key}"
for key in ["enablePurgeProtection", "enableSoftDelete", "enableRbacAuthorization", "networkAcls", "publicNetworkAccess", "softDeleteRetentionInDays"]:
    assert before.get(key) == after.get(key), f"Vault setting changed: {key}"
assert set(updated) == set(existing) | {principal}, "Unexpected policy principal change"
print(f"{name}: verified existing policies and vault settings preserved")
