locals {
  environment             = "sbox"
  location                = "uksouth"
  image_version           = "1.0.4"
  subnet                  = "10.48.0.96/28"
  jumpbox_subnet          = "10.48.0.112/28"
  hub_subscription_id     = "ea3a8c1e-af9d-4108-bc86-a7e2d267f49c"
  hub_vnet_name           = "hmcts-hub-sbox-int"
  hub_vnet_resource_group = "hmcts-hub-sbox-int"
  hub_lb_name             = "hmcts-hub-sbox-int-palo-lb"
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
    }

  ]
}
