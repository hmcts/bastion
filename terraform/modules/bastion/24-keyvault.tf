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

data "azurerm_key_vault" "soc_vault" {
  count    = var.install_splunk_uf ? 1 : 0
  provider = azurerm.soc

  name                = var.soc_vault_name
  resource_group_name = var.soc_vault_rg
}

data "azurerm_key_vault_secret" "splunk_username" {
  count    = var.install_splunk_uf ? 1 : 0
  provider = azurerm.soc

  name         = var.splunk_username_secret
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

data "azurerm_key_vault_secret" "splunk_password" {
  count    = var.install_splunk_uf ? 1 : 0
  provider = azurerm.soc

  name         = var.splunk_password_secret
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}

data "azurerm_key_vault_secret" "splunk_pass4symmkey" {
  count    = var.install_splunk_uf ? 1 : 0
  provider = azurerm.soc

  name         = var.splunk_pass4symmkey_secret
  key_vault_id = data.azurerm_key_vault.soc_vault[0].id
}
