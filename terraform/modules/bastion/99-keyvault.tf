
# # Key Vault

# resource "azurerm_key_vault" "key_vault" {
#   name                            = "${var.bastion_name}infra${var.environment}kv"
#   resource_group_name             = azurerm_resource_group.bastion_infra_resource_group.name
#   location                        = azurerm_resource_group.bastion_infra_resource_group.location

#   sku_name = "standard"

#   tenant_id = data.azurerm_client_config.current.tenant_id

#   enabled_for_deployment          = "true"
#   enabled_for_disk_encryption     = "true"
#   enabled_for_template_deployment = "true"

#   tags                            = var.tags
# }

# resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {
#   key_vault_id = azurerm_key_vault.key_vault.id

#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = data.azurerm_client_config.current.object_id

#   key_permissions = [
#     "create",
#     "decrypt",
#     "delete",
#     "encrypt",
#     "get",
#     "import",
#     "list",
#     "purge",
#     "recover",
#     "restore",
#     "sign",
#     "unwrapKey",
#     "update",
#     "verify",
#     "wrapKey",
#   ]

#   secret_permissions = [
#     "backup",
#     "delete",
#     "get",
#     "list",
#     "purge",
#     "recover",
#     "restore",
#     "set",
#   ]
# }

# resource "azurerm_key_vault_secret" "bastion_admin_username" {
#   name         = "admin-username"
#   value        = var.admin_username
#   key_vault_id = azurerm_key_vault.key_vault.id

#   tags        = var.tags
# }

# resource "azurerm_key_vault_secret" "bastion_admin_password" {
#   name         = "admin-password"
#   value        = var.admin_password
#   key_vault_id = azurerm_key_vault.key_vault.id

#   tags        = var.tags
# }

# resource "azurerm_key_vault_secret" "bastion_ssh_public_key" {
#   name         = "ssh-public-key"
#   value        = var.ssh-public-key
#   key_vault_id = azurerm_key_vault.key_vault.id

#   tags        = var.tags
# }

# resource "azurerm_key_vault_secret" "bastion_ssh_private_key" {
#   name         = "ssh-private-key"
#   value        = var.ssh-private-key
#   key_vault_id = azurerm_key_vault.key_vault.id

#   tags        = var.tags
# }