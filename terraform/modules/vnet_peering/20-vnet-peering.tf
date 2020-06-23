resource "azurerm_virtual_network_peering" "bastion-to-hub" {
  name                      = "${var.bastion_vnet_name}-to-hub"
  resource_group_name       = var.bastion_vnet_resource_group
  virtual_network_name      = var.bastion_vnet_name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "hub-to-bastion" {
  name                      = "hub-to-${var.bastion_vnet_name}"
  resource_group_name       = var.hub_vnet_resource_group
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = var.bastion_vnet_id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}