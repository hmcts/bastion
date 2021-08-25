resource "azurerm_key_vault_secret" "bastion_admin_username" {
  name         = "${var.bastion_name}-admin-username"
  value        = azurerm_linux_virtual_machine.bastion.admin_username
  key_vault_id = var.keyvault_id
  tags         = local.common_tags
}

resource "azurerm_key_vault_secret" "bastion_ssh_public_key" {
  name         = "${var.bastion_name}-public-key"
  value        = file("../../environment/${var.environment}/${var.public_key}")
  key_vault_id = var.keyvault_id
}

resource "tls_private_key" "bastion_ssh_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "bastion_ssh_private_key" {
  name         = "${var.bastion_name}-private-key"
  value        = tls_private_key.bastion_ssh_private_key.private_key_pem
  key_vault_id = var.keyvault_id
}