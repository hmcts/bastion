locals {
  environment             = "prod"
  location                = "uksouth"
  image_version           = "1.0.3"
  subnet                  = "10.48.0.0/27"
  jumpbox_subnet          = "10.48.2.0/28"
  AzureBastionSubnet      = "10.18.117.0/24"
  hub_subscription_id     = "0978315c-75fe-4ada-9d11-1eb5e0e0b214"
  hub_vnet_name           = "hmcts-hub-prod-int"
  hub_vnet_resource_group = "hmcts-hub-prod-int"
  hub_lb_name             = "hmcts-hub-prod-int-palo-lb"
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
      name                   = "pet_stg_network"
      address_prefix         = "192.170.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = data.azurerm_lb.hub_palo.frontend_ip_configuration.1.private_ip_address
    },
    {
      name                   = "pet_prod_network"
      address_prefix         = "192.169.0.0/16"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = data.azurerm_lb.hub_palo.frontend_ip_configuration.1.private_ip_address
    }

  ]
}
