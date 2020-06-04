resource "azurerm_key_vault_secret" "bastion_admin_username" {
  name         = "${var.bastion_name}-admin-username"
  value        = azurerm_linux_virtual_machine.bastion.admin_username
  key_vault_id = var.keyvault_id
  tags         = local.common_tags
}

resource "azurerm_key_vault_secret" "bastion_ssh_public_key" {
  name         = "${var.bastion_name}-public-key"
  value        = file("../../component/${var.environment}/id_rsa_bastion.pub")
  key_vault_id = var.keyvault_id
}

resource "azurerm_key_vault_secret" "bastion_ssh_private_key" {
  name         = "${var.bastion_name}-private-key"
  value        = "update me the private key"
  key_vault_id = var.keyvault_id
}