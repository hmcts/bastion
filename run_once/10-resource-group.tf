#--------------------------------------------------------------
# Resource Group
#--------------------------------------------------------------

resource "azurerm_resource_group" "bastion_infra_resource_group" {
  location = var.location
  name = "${var.bastion_name}_infra_${var.environment}_rg"
}
