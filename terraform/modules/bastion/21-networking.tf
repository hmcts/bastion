
resource "azurerm_virtual_network" "bastion" {
  name                = var.vnet_name
  resource_group_name = azurerm_resource_group.bastion.name
  location            = azurerm_resource_group.bastion.location
  tags                = local.common_tags
  
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "bastion" {
  name                 = var.bastion_name
  resource_group_name  = azurerm_resource_group.bastion.name
  virtual_network_name = azurerm_virtual_network.bastion.name
  address_prefix       = var.vnet_subnet_address
}

resource "azurerm_network_interface" "bastion" {
  name                = "${var.bastion_name}-nic"
  resource_group_name = azurerm_resource_group.bastion.name
  location            = azurerm_resource_group.bastion.location
  tags                = local.common_tags

  ip_configuration {
    name                          = "${var.bastion_name}-ip"
    subnet_id                     = azurerm_subnet.bastion.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_network_interface_security_group_association" "bastion" {
  network_interface_id      = azurerm_network_interface.bastion.id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_public_ip" "bastion" {
  name                = "${var.bastion_name}-pip"
  resource_group_name = azurerm_resource_group.bastion.name
  location            = azurerm_resource_group.bastion.location
  tags                = local.common_tags

  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "bastion" {
  name                = "${var.bastion_name}-nsg"
  resource_group_name = azurerm_resource_group.bastion.name
  location            = azurerm_resource_group.bastion.location
  tags                = local.common_tags
}

resource "azurerm_network_security_rule" "bastion" {
  network_security_group_name = azurerm_network_security_group.bastion.name 
  resource_group_name         = azurerm_resource_group.bastion.name
  name                        = "SSH-in"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}