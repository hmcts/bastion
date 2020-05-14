#--------------------------------------------------------------
# Subnet
#--------------------------------------------------------------

resource "azurerm_subnet" "bastion_subnet" {
  name                            = "${var.bastion_name}-subnet"
  resource_group_name             = azurerm_resource_group.bastion_resource_group.name

  virtual_network_name            = azurerm_virtual_network.bastion_vnet.name
  address_prefixes                = var.address_space
}


#--------------------------------------------------------------
# Bastion Network Interface
#--------------------------------------------------------------


resource "azurerm_network_interface" "bastion_nic" {
  name                            = "${var.virtual_machine_name}-${format("%02d",count.index)}-nic"
  resource_group_name             = azurerm_resource_group.bastion_resource_group.name
  location                        = azurerm_resource_group.bastion_resource_group.location

  count                           = var.virtual_machine_count
  tags                            = var.tags

  ip_configuration {
    name                          = "${var.virtual_machine_name}-${format("%02d",count.index)}-ip"
    subnet_id                     = azurerm_subnet.bastion_subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_public_ip.*.id[count.index]
  }
}


#--------------------------------------------------------------
# Public IP Address
#--------------------------------------------------------------


resource "azurerm_public_ip" "bastion_public_ip" {
  name                            = "${var.virtual_machine_name}-${format("%02d",count.index)}-pip"
  resource_group_name             = azurerm_resource_group.bastion_resource_group.name
  location                        = azurerm_resource_group.bastion_resource_group.location

  allocation_method               = "Static"
  count                           = var.virtual_machine_count
  tags                            = var.tags
}