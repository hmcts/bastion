module "azure-bastion" {
  source                   = "../../modules/azure_bastion/"
  environment           = local.environment
  resource_group_name      = module.bootstrap.resource_group.name
  virtual_network_name     = module.bootstrap.vnet
  azbastion_subnet_address = local.AzureBastionSubnet

  public_ip_name    = "pub-ip-bastion-${local.environment}"
  location          = module.bootstrap.resource_group.location
  allocation_method = local.allocation_method
  public_ip_sku     = local.public_ip_sku


  bastion_name      = "azure-bastion-${local.environment}"
  bastion_sku       = local.bastion_sku
  tunneling_enabled = local.tunneling_enabled
  ip_config_name    = local.ip_config_name

}