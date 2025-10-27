module "bastion-nonprod" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_version       = local.image_version
  image_name          = local.image_name
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-nonprod"
  disk_size           = "2000"
  storage_type        = "StandardSSD_LRS"
  create_disks        = true
  # Dynatrace OneAgent
  cnp_vault_rg        = "cnp-core-infra"
  cnp_vault_sub       = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
  dynatrace_tenant_id = "yrk32651"
  dynatrace_server    = "https://dynatrace-activegate-nonprod.platform.hmcts.net:9999/e/yrk32651/api"
  # Tenable Nessus
  nessus_server     = "nessus-scanners-nonprod000005.platform.hmcts.net"
  nessus_key_secret = "nessus-agent-key-nonprod"
  autoShutdown      = true
}

module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = "https://github.com/hmcts/bastion"
  environment  = local.environment
  product      = "mgmt"
  expiresAfter = "3000-01-01" # never expire bastions
  autoShutdown = false
}

resource "azurerm_managed_disk" "disk" {
  name                 = "bastion-nonprod-datadisk-temp"
  location             = module.bootstrap.resource_group.location
  resource_group_name  = module.bootstrap.resource_group.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = "2000"
  tags                 = module.ctags.common_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "diskattach" {
  managed_disk_id    = azurerm_managed_disk.disk.id
  virtual_machine_id = module.bastion-nonprod.virtual_machine.id
  lun                = 0
  caching            = "ReadWrite"
}
