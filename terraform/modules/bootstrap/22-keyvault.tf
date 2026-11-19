resource "azurerm_key_vault" "bastion" {
  name                = var.keyvault_name
  resource_group_name = azurerm_resource_group.bastion.name
  location            = azurerm_resource_group.bastion.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  tags                = module.ctags.common_tags

  purge_protection_enabled = false

  dynamic "access_policy" {
    for_each = concat(
      var.additional_key_vault_access_policies,
      [for caller in [{
        object_id          = data.azurerm_client_config.current.object_id
        secret_permissions = ["Get", "List", "Set", "Delete"]
      }] : caller if !contains([for policy in var.additional_key_vault_access_policies : policy.object_id], caller.object_id)]
    )

    content {
      tenant_id          = data.azurerm_client_config.current.tenant_id
      object_id          = access_policy.value.object_id
      secret_permissions = access_policy.value.secret_permissions
    }
  }
}
