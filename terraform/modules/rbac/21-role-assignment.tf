resource "azurerm_role_assignment" "bastion-admin" {
  scope              = var.role_assignment_scope
  role_definition_id = "Virtual Machine Admin Login"
  principal_id       = var.bastion_admin_group_object_id
}

resource "azurerm_role_assignment" "bastion-user" {
  scope              = var.role_assignment_scope
  role_definition_id = "Virtual Machine User Login"
  principal_id       = var.bastion_user_group_object_id
}