locals {
  environment             = "nonprod"
  location                = "uksouth"
  image_id                = "1.0.2"
  subnet                  = "10.48.0.32/27"
  hub_subscription_id     = "fb084706-583f-4c9a-bdab-949aac66ba5c"
  hub_vnet_name           = "hmcts-hub-nonprodi"
  hub_vnet_resource_group = "hmcts-hub-nonprodi"
  hub_lb_name             = "hmcts-hub-nonprodi-palo-lb"
  hub_lb_resource_group   = local.hub_vnet_resource_group
}
