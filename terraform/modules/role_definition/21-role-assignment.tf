data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "bastion-admin" {
  scope              = var.role_assignment_scope
  role_definition_id = azurerm_role_definition.bastion-admin.id
  principal_id       = data.azurerm_client_config.current.client_id
}