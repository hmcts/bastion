#--------------------------------------------------------------
# Resource Group
#--------------------------------------------------------------

resource "azurerm_resource_group" "bastion_resource_group" {
  location = var.location

  name = "${var.bastion_name}-${var.environment}-rg"
}
