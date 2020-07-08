resource "azurerm_virtual_network_peering" "bastion-to-hub" {
  name                      = "${var.bastion_vnet_name}-to-hub"
  resource_group_name       = var.bastion_vnet_name
  virtual_network_name      = var.bastion_vnet_resource_group
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "hub-to-bastion" {
  provider = azurerm.hub

  name                      = "hub-to-${var.bastion_vnet_name}"
  resource_group_name       = data.azurerm_virtual_network.hub.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = var.bastion_vnet_id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}