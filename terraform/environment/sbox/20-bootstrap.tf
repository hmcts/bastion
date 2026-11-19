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
    "43e023d9-c617-471f-aeda-2ad0efb97aac" = ["Get", "List", "Set", "Delete"]
    "083265d1-2e54-40ef-83bc-34fd5a1f1bcf" = ["Delete", "Get", "List", "Set"]
  }
}