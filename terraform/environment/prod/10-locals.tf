locals {
  environment             = "prod"
  location                = "uksouth"
  image_id                = "/subscriptions/2b1afc19-5ca9-4796-a56f-574a58670244/resourceGroups/rdo-bastion-packer/providers/Microsoft.Compute/images/rdo-bastion-image-85811"
  subnet                  = "10.48.0.0/27"
  hub_subscription_id     = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
  hub_vnet_name           = "hmcts-hub-prod-int"
  hub_vnet_resource_group = "hmcts-hub-prod-int"
  hub_lb_name             = "hmcts-hub-prod-int-palo-lb"
  hub_lb_resource_group   = local.hub_vnet_resource_group
}
