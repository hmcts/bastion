# Reform DevOps Bastion Host Provisioning

## Overview

This will build a Bastion host in the desired DMZ network and peer into all the correct networks, for the Reform DevOps to utilise.

As part of the build this will create an empty KeyVault - You will need to populate this keyvault before running the job a second time, as the 
build requires the following vaules

Need to add following to keyvault
admin-password
admin-username
client-id
client-secret
subscription-id
tenant-id

## Build Pipeline

This build job existing within the HMCTS Azure DevOps Project:
https://dev.azure.com/HMCTS-DEVOPS/reform-devops

As part of this build pipeline, during the Terraform Apply Stage I've included some additional OS and SSH hardening Ansibles Roles, which is
called from the following location:

https://github.com/dev-sec/
https://dev-sec.io/

These roles are kept upto date with all current Security and vulnerability alerts

Ansible-Galaxy Roles:
- src: dev-sec.ssh-hardening
- src: dev-sec.os-hardening

Running these roles, will help reduce your Surface Area of attack, ensure your Server and Core configurations is Secure to industry Standards, these 2 roles will NOT maintain your Patch Management and more complex configurations like Firewalls / SELinux etc.


## Terraform Module

This is a terraform module for creating an bastion host in Azure

## Usage
```
module "rdo-uks-bastion" {
  source                = "git@github.com:hmcts/rdo-uks-bastion//terraform"
  bastion_name          = "HOST / STROAGE Name"
  resource_group        = "RESOURCE GROUP MATCH BASTION NAME WITH -RG at END"
  key_vault_uri         = "https://KEY_VAULT_LOOKUP_NAME.vault.azure.net/"
  location              = "LOCATION"
  virtual_machine_count = 1
  address_space         = "IP_RANGE"
  ssh_key               = "SSH_PUBLIC_KEY_PATH"
}
```