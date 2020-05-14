#--------------------------------------------------------------
# Security Group
#--------------------------------------------------------------


resource "azurerm_network_security_group" "bastion_nsg" {
  name                            = "${var.bastion_name}-nsg"
  resource_group_name             = azurerm_resource_group.bastion_resource_group.name
  location                        = azurerm_resource_group.bastion_resource_group.location

  tags                            = var.tags
}

#--------------------------------------------------------------
# Security Rules
#--------------------------------------------------------------


resource "azurerm_network_security_rule" "bastion_nsg_rule_ssh" {
  name                            = "SSH-in"
  priority                        = 200
  direction                       = "Inbound"
  access                          = "Allow"
  protocol                        = "Tcp"
  source_port_range               = "*"
  destination_port_range          = 22
  source_address_prefix           = "*"
  destination_address_prefix      = "*"
  resource_group_name             = azurerm_resource_group.bastion_resource_group.name
  network_security_group_name     = azurerm_network_security_group.bastion_nsg.name 
}