resource "azurerm_key_vault_secret" "bastion_admin_username" {
  name         = "${var.bastion_name}-admin-username"
  value        = azurerm_linux_virtual_machine.bastion.admin_username
  key_vault_id = var.keyvault_id
  tags         = local.common_tags
}

resource "tls_private_key" "bastion_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "bastion_ssh_public_key" {
  name         = "${var.bastion_name}-public-key"
  value        = tls_private_key.bastion_ssh_key.public_key_openssh
  key_vault_id = var.keyvault_id
}

resource "azurerm_key_vault_secret" "bastion_ssh_private_key" {
  name         = "${var.bastion_name}-private-key"
  value        = tls_private_key.bastion_ssh_key.private_key_pem
  key_vault_id = var.keyvault_id
}