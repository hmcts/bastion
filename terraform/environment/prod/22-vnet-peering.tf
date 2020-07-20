module "bastion-devops-peering" {
  source                      = "../../modules/vnet_peering/"
  bastion_vnet_name           = module.bootstrap.vnet.name
  bastion_vnet_resource_group = module.bootstrap.vnet.resource_group_name
  hub_vnet_name               = "hmcts-hub-prod-int"
  hub_vnet_resource_group     = "hmcts-hub-prod-int"
  hub_subscription_id         = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
}

module "bastion-peering-to-vpn" {
  source                      = "../../modules/vpn_peering/"
  bastion_vnet_name           = module.bootstrap.vnet.name
  bastion_vnet_resource_group = module.bootstrap.vnet.resource_group_name
  vpn_vnet_name               = "core-infra-vnet-mgmt"
  vpn_vnet_resource_group     = "rg-mgmt"
  vpn_subscription_id         = "ed302caf-ec27-4c64-a05e-85731c3ce90e"
}