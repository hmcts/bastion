resource "azurerm_role_assignment" "bastion-admin" {
  count = var.role_assignment_scope == "" ? 0 : 1

  scope              = var.role_assignment_scope
  role_definition_id = azurerm_role_definition.bastion-admin.id
  principal_id       = var.bastion_admin_group_object_id
}

resource "azurerm_role_assignment" "bastion-user" {
  count = var.role_assignment_scope == "" ? 0 : 1

  scope              = var.role_assignment_scope
  role_definition_id = azurerm_role_definition.bastion-admin.id
  principal_id       = var.bastion_user_group_object_id
}