resource "azurerm_virtual_network" "bastion" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.bastion.name
  location            = azurerm_resource_group.bastion.location
  tags                = local.common_tags
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "bastion" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.bastion.name
  virtual_network_name = azurerm_virtual_network.bastion.name
  address_prefix       = var.subnet_address
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_route_table" "bastion" {
  name                          = "bastion-${var.environment}-udr"
  resource_group_name           = azurerm_resource_group.bastion.name
  location                      = azurerm_resource_group.bastion.location
  disable_bgp_route_propagation = true
  tags                          = local.common_tags

  route {
    name                   = "PrivateA"
    address_prefix         = "10.0.0.0/8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.azurerm_lb.hub_palo.frontend_ip_configuration.1.private_ip_address
  }

  route {
    name                   = "PrivateB"
    address_prefix         = "172.16.0.0/12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.azurerm_lb.hub_palo.frontend_ip_configuration.1.private_ip_address
  }

  route {
    name                   = "PrivateC"
    address_prefix         = "192.168.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.azurerm_lb.hub_palo.frontend_ip_configuration.1.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "bastion" {
  subnet_id      = azurerm_subnet.bastion.id
  route_table_id = azurerm_route_table.bastion.id
}