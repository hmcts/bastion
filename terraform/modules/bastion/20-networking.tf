resource "azurerm_network_interface" "bastion" {
  name                = "${var.bastion_name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = module.ctags.common_tags

  ip_configuration {
    name                          = "${var.bastion_name}-ip"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "bastion" {
  network_interface_id      = azurerm_network_interface.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_network_security_group" "bastion" {
  name                = "${var.bastion_name}-nsg"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = module.ctags.common_tags
}

resource "azurerm_network_security_rule" "bastion" {
  network_security_group_name = azurerm_network_security_group.bastion.name
  resource_group_name         = var.resource_group_name
  name                        = "SSH-in-from-VPN"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "10.99.2.0/23"
  destination_address_prefix  = "*"
}
