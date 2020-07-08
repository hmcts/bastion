module "bastion-devops-peering" {
  source                      = "../../modules/vnet_peering/"
  bastion_vnet_name           = module.bootstrap.vnet.name
  bastion_vnet_resource_group = module.bootstrap.vnet.resource_group_name
  hub_vnet_name               = "hmcts-hub-nonprodi"
  hub_vnet_resource_group     = "hmcts-hub-nonprodi"
  hub_subscription_id         = "fb084706-583f-4c9a-bdab-949aac66ba5c"
}