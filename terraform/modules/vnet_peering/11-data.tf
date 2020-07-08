data "azurerm_virtual_machine" "bastion" {
  name                = var.bastion_vnet_name
  resource_group_name = var.bastion_vnet_resource_group
}

data "azurerm_virtual_network" "hub" {
  provider = azurerm.hub

  name                = var.hub_vnet_name
  resource_group_name = var.hub_vnet_resource_group
}