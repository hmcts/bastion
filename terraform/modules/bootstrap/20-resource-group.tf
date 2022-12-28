resource "azurerm_resource_group" "bastion" {
  location = var.location
  name     = var.resource_group_name
  tags     = module.ctags.common_tags
}
