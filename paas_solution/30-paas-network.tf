#--------------------------------------------------------------
# Subnet
#--------------------------------------------------------------


resource "azurerm_subnet" "subnet-bastion" {
  name                      = "AzureBastionSubnet"
  resource_group_name       = azurerm_resource_group.bastion_resource_group.name
  virtual_network_name      = azurerm_virtual_network.bastion_vnet.name
  address_prefixes          = var.address_space
}

#--------------------------------------------------------------
# Public IP Address
#--------------------------------------------------------------


resource "azurerm_public_ip" "bastion_pip" {
  name                      = "bastion-${var.environment}-pip"
  resource_group_name       = azurerm_resource_group.bastion_resource_group.name
  location                  = azurerm_resource_group.bastion_resource_group.location
 
  allocation_method         = "Static"
  sku                       = "Standard"
}