resource "azurerm_role_assignment" "bastion-admin" {
  provider = azurerm.bastion

  count = var.bastion_access_admin_group_name == "" ? 0 : 1

  scope              = data.azurerm_virtual_machine.bastion.id
  role_definition_id = "Virtual Machine Admin Login"
  principal_id       = data.azuread_group.bastion-admin.id
}

resource "azurerm_role_assignment" "bastion-user" {
  provider = azurerm.bastion
  
  count = var.bastion_access_user_group_name == "" ? 0 : 1

  scope              = data.azurerm_virtual_machine.bastion.id
  role_definition_id = "Virtual Machine User Login"
  principal_id       = data.azuread_group.bastion-user.id
}