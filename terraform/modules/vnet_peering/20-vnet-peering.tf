resource "azurerm_virtual_network_peering" "bastion-to-hub" {
  name                      = "${data.azurerm_virtual_network.bastion.name}-to-hub"
  resource_group_name       = data.azurerm_virtual_machine.bastion.name
  virtual_network_name      = data.azurerm_virtual_machine.bastion.resource_group_name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "hub-to-bastion" {
  provider = azurerm.hub

  name                      = "hub-to-${data.azurerm_virtual_machine.bastion.name}"
  resource_group_name       = data.azurerm_virtual_network.hub.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = data.azurerm_virtual_network.bastion.id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}