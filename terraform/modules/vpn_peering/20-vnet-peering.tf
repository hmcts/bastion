resource "azurerm_virtual_network_peering" "bastion-to-vpn" {
  name                      = "${data.azurerm_virtual_network.bastion.name}-to-vpn"
  resource_group_name       = data.azurerm_virtual_network.bastion.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.bastion.name
  remote_virtual_network_id = data.azurerm_virtual_network.vpn.id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}