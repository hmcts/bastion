resource "azurerm_role_assignment" "bastion-admin" {
  for_each = toset(var.bastion_admin_object_id)

  scope              = var.role_assignment_scope
  role_definition_id = azurerm_role_definition.bastion-admin.id
  principal_id       = each.value
}

resource "azurerm_role_assignment" "bastion-user" {
  for_each = toset(var.bastion_users_object_id)

  scope              = var.role_assignment_scope
  role_definition_id = azurerm_role_definition.bastion-admin.id
  principal_id       = each.value
}