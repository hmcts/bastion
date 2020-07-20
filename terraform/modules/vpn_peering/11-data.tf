data "azurerm_virtual_network" "bastion" {
  provider = azurerm.bastion

  name                = var.bastion_vnet_name
  resource_group_name = var.bastion_vnet_resource_group
}

data "azurerm_virtual_network" "vpn" {
  provider = azurerm.vpn

  name                = var.vpn_vnet_name
  resource_group_name = var.vpn_vnet_resource_group
}