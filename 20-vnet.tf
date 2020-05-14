#--------------------------------------------------------------
# Virtual Network
#--------------------------------------------------------------

resource "azurerm_virtual_network" "bastion_vnet" {
  name                            = "${var.bastion_name}-${var.environment}-vn"
  resource_group_name             = azurerm_resource_group.bastion_resource_group.name
  location                        = azurerm_resource_group.bastion_resource_group.location
  address_space                   = var.address_space

  tags                            = var.tags
}



