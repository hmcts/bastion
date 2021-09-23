data "azurerm_virtual_machine" "bastion" {
  provider = azurerm.bastion

  name                = var.bastion_vm_name
  resource_group_name = var.bastion_resource_group
}

data "azuread_group" "bastion-admin" {
  name = var.bastion_access_admin_group_name
}

data "azuread_group" "bastion-user" {
  name = var.bastion_access_user_group_name
}