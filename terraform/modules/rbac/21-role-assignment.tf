resource "azurerm_role_assignment" "bastion-admin" {
  provider           = azurerm.bastion
  scope              = data.azurerm_virtual_machine.bastion.id
  role_definition_id = var.aad_role_def_id_admin
  principal_id       = data.azuread_group.bastion-admin.id
}

resource "azurerm_role_assignment" "bastion-user" {
  provider           = azurerm.bastion
  scope              = data.azurerm_virtual_machine.bastion.id
  role_definition_id = var.aad_role_def_id_user
  principal_id       = data.azuread_group.bastion-user.id
}

resource "azurerm_role_assignment" "bastion-user-workaround" {
  for_each           = toset(var.aad_workaround_users)
  provider           = azurerm.bastion
  scope              = data.azurerm_virtual_machine.bastion.id
  role_definition_id = var.aad_role_def_id_user
  principal_id       = each.value
}
