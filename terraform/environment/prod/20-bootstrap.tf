module "bootstrap" {
  source                = "../../modules/bootstrap/"
  location              = local.location
  environment           = local.environment
  resource_group_name   = "bastion-${local.environment}-rg"
  vnet_name             = "bastion-${local.environment}-vnet"
  keyvault_name         = "bastion-${local.environment}-hmcts-kv"
  subnet_name           = "bastion"
  subnet_address        = local.subnet
  vnet_address_space    = [local.subnet, local.jumpbox_subnet]
  hub_subscription_id   = local.hub_subscription_id
  hub_lb_name           = local.hub_lb_name
  hub_lb_resource_group = local.hub_lb_resource_group
  routes                = local.routes

  additional_key_vault_access_policies = {
    "b7a68ebf-8ace-4855-9ea6-1f08ef0af8f9" = ["Get", "List", "Set", "Delete"]
    "5d16e46d-017b-4ae0-859c-22a10cce59e9" = ["Delete", "Get", "List", "Set"]
    "0f11e5e9-83e3-442f-a015-a6bda75912cd" = ["Get", "List"]
  }
}
