module "bastion-prod" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_version       = local.image_version
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-prod"
  disk_size           = "1000"
  storage_type        = "StandardSSD_LRS"
  create_disks        = true
  # Dynatrace OneAgent
  cnp_vault_rg        = "core-infra-prod"
  cnp_vault_sub       = "8999dec3-0104-4a27-94ee-6588559729d1"
  dynatrace_tenant_id = "ebe20728"
  dynatrace_server    = "https://dynatrace-activegate-prod.platform.hmcts.net:9999/e/ebe20728/api"
  # Tenable Nessus
  nessus_server     = "nessus-scanners-prod000005.platform.hmcts.net"
  nessus_key_secret = "nessus-agent-key-prod"
  common_tags       = module.ctags.common_tags
}

module "bastion-secops" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_version       = local.image_version
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-secops-prod"
  # Dynatrace OneAgent
  cnp_vault_rg        = "core-infra-prod"
  cnp_vault_sub       = "8999dec3-0104-4a27-94ee-6588559729d1"
  dynatrace_tenant_id = "ebe20728"
  dynatrace_server    = "https://dynatrace-activegate-prod.platform.hmcts.net:9999/e/ebe20728/api"
  # Tenable Nessus
  nessus_server     = "nessus-scanners-prod000005.platform.hmcts.net"
  nessus_key_secret = "nessus-agent-key-prod"
  common_tags       = module.ctags.common_tags
}

module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = "https://github.com/hmcts/bastion"
  environment  = var.environment
  product      = "mgmt"
  expiresAfter = "3000-01-01"
}
