module "bootstrap" {
  source                = "../../modules/bootstrap/"
  location              = local.location
  environment           = local.environment
  resource_group_name   = "bastion-${local.environment}-rg"
  vnet_name             = "bastion-${local.environment}-vnet"
  keyvault_name         = "bastion-${local.environment}-kv"
  subnet_name           = "bastion"
  subnet_address        = local.subnet
  vnet_address_space    = [local.subnet, local.jumpbox_subnet]
  hub_subscription_id   = local.hub_subscription_id
  hub_lb_name           = local.hub_lb_name
  hub_lb_resource_group = local.hub_lb_resource_group
  routes                = local.routes

  additional_key_vault_access_policies = {
    "29e4829a-6912-4285-8573-0afd9c5b70d8" = ["Get", "List", "Set", "Delete"]
    "65326fe1-e4fe-444a-becb-d7f6a53091df" = ["Get", "List", "Set", "Delete"]
  }
}