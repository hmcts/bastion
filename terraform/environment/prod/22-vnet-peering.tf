module "bastion-devops-peering" {
  source                      = "../../modules/vnet_peering/"
  bastion_vnet_name           = module.bootstrap.vnet.name
  bastion_vnet_resource_group = module.bootstrap.vnet.resource_group_name
  hub_vnet_name               = "hmcts-hub-prod-int"
  hub_vnet_resource_group     = "hmcts-hub-prod-int"
  hub_subscription_id         = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
}