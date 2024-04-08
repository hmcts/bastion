module "bastion-sbox" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_version       = local.image_version
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-sbox"
  disk_size           = "100"
  storage_type        = "StandardSSD_LRS"
  create_disks        = true
  # Dynatrace OneAgent
  cnp_vault_rg        = "cnp-core-infra"
  cnp_vault_sub       = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
  dynatrace_tenant_id = "yrk32651"
  dynatrace_server    = "https://dynatrace-activegate-nonprod.platform.hmcts.net:9999/e/yrk32651/api"
  # Tenable Nessus
  nessus_server       = "nessus-scanners-sbox000006.platform.hmcts.net"
  nessus_key_secret   = "nessus-agent-key-sbox"
  vm_bootstrap_source = "github.com/hmcts/terraform-module-vm-bootstrap?ref=DTSPO-17050-splunk-usf-version-update"

}

# Configuration for SecOps bastion
module "bastion-secops-sbox" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_version       = local.image_version
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-secops-sbox"
  # Dynatrace OneAgent
  cnp_vault_rg        = "cnp-core-infra"
  cnp_vault_sub       = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
  dynatrace_tenant_id = "yrk32651"
  dynatrace_server    = "https://dynatrace-activegate-nonprod.platform.hmcts.net:9999/e/yrk32651/api"
  # Tenable Nessus
  nessus_server     = "nessus-scanners-sbox000006.platform.hmcts.net"
  nessus_key_secret = "nessus-agent-key-sbox"
}
