# module "bastion-devops-peering" {
#   source                      = "../../modules/vnet_peering/"
#   bastion_vnet_name           = module.bootstrap.vnet.name
#   bastion_vnet_resource_group = module.bootstrap.vnet.resource_group_name
#   bastion_vnet_id             = module.bootstrap.vnet.id
#   hub_vnet_name               = "hmcts-dmz-nonprodi"
#   hub_vnet_resource_group     = "hmcts-hub-nonprodi"
#   hub_vnet_id                 = "caa9aa2e-7272-45ea-abec-4140678de647"
# }