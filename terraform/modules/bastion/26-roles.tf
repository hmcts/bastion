data "azuread_group" "platform_operations" {
  display_name = "DTS Platform Operations"
}

resource "azurerm_role_assignment" "vm_admin_login" {
  role_definition_name = "Virtual Machine Administrator Login"
  scope                = azurerm_linux_virtual_machine.bastion.id
  principal_id         = data.azuread_group.platform_operations.id
}