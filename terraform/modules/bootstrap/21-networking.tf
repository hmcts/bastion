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
  address_prefixes     = [var.subnet_address]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_route_table" "bastion" {
  name                          = "bastion-${var.environment}-udr"
  resource_group_name           = azurerm_resource_group.bastion.name
  location                      = azurerm_resource_group.bastion.location
  disable_bgp_route_propagation = true
  tags                          = local.common_tags
  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.value["name"]
      address_prefix         = route.value["address_prefix"]
      next_hop_type          = route.value["next_hop_type"]
      next_hop_in_ip_address = route.value["next_hop_in_ip_address"]
    }
  }

}

resource "azurerm_subnet_route_table_association" "bastion" {
  subnet_id      = azurerm_subnet.bastion.id
  route_table_id = azurerm_route_table.bastion.id
}
