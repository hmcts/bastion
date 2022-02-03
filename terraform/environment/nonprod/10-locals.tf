locals {
  environment             = "nonprod"
  location                = "uksouth"
  image_version           = "1.0.2"
  subnet                  = "10.48.0.32/27"
  hub_subscription_id     = "fb084706-583f-4c9a-bdab-949aac66ba5c"
  hub_vnet_name           = "hmcts-hub-nonprodi"
  hub_vnet_resource_group = "hmcts-hub-nonprodi"
  hub_lb_name             = "hmcts-hub-nonprodi-palo-lb"
  hub_lb_resource_group   = local.hub_vnet_resource_group
  routes = [
    {
      name                   = "PrivateA"
      address_prefix         = "10.0.0.0/8"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = data.azurerm_lb.hub_palo.frontend_ip_configuration.1.private_ip_address
    },
    {
      name                   = "PrivateB"
      address_prefix         = "172.16.0.0/12"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = data.azurerm_lb.hub_palo.frontend_ip_configuration.1.private_ip_address
    },
    {
      name                   = "PrivateC"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = data.azurerm_lb.hub_palo.frontend_ip_configuration.1.private_ip_address
    },
    {
      name                   = "pet_dev_network"
      address_prefix         = "192.168.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = data.azurerm_lb.hub_palo.frontend_ip_configuration.1.private_ip_address
    }

  ]
}
