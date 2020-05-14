#--------------------------------------------------------------
# Bastion Host
#--------------------------------------------------------------


resource "azurerm_bastion_host" "bastion_host" {
  name                      = "bastion-${var.environment}-host"
  resource_group_name       = azurerm_resource_group.bastion_resource_group.name
  location                  = azurerm_resource_group.bastion_resource_group.location

  ip_configuration {
    name                    = "configuration"
    subnet_id               = azurerm_subnet.subnet-bastion.id
    public_ip_address_id    = azurerm_public_ip.bastion_pip.id
  }

  tags                      = var.tags
} 
