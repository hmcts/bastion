module "azure-bastion" {
  source                   = "git@github.com:hmcts/terraform-module-azure-bastion.git?ref=main"
  env                      = local.environment
  resource_group_name      = module.bootstrap.resource_group.name
  virtual_network_name     = module.bootstrap.vnet.name
  azbastion_subnet_address = [local.AzureBastionSubnet]

  public_ip_name    = "pub-ip-bastion-${local.environment}"
  location          = module.bootstrap.resource_group.location
  allocation_method = local.allocation_method
  public_ip_sku     = local.public_ip_sku


  bastion_name      = "azure-bastion-${local.environment}"
  bastion_sku       = local.bastion_sku
  tunneling_enabled = local.tunneling_enabled
  ip_config_name    = local.ip_config_name

  builtFrom = "https://github.com/hmcts/bastion"
  product   = "mgmt"
}