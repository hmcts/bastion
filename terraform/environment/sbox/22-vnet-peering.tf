module "bastion-devops-peering" {
  source                      = "../../modules/vnet_peering/"
  bastion_vnet_name           = module.bootstrap.vnet.name
  bastion_vnet_resource_group = module.bootstrap.vnet.resource_group_name
  hub_vnet_name               = "hmcts-hub-sbox-int"
  hub_vnet_resource_group     = "hmcts-hub-sbox-int"
  hub_subscription_id         = "ea3a8c1e-af9d-4108-bc86-a7e2d267f49c"
}