resource "azurerm_key_vault_secret" "bastion_admin_username" {
  name         = "${var.bastion_name}-admin-username"
  value        = azurerm_linux_virtual_machine.bastion.admin_username
  key_vault_id = var.keyvault_id
  tags         = module.ctags.common_tags
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

# Dynatrace OneAgent
data "azurerm_key_vault" "cnp_vault" {
  provider = azurerm.cnp

  name                = "infra-vault-${local.dynatrace_env}"
  resource_group_name = var.cnp_vault_rg
}

data "azurerm_key_vault_secret" "token" {
  provider = azurerm.cnp

  name         = "dynatrace-${local.dynatrace_env}-token"
  key_vault_id = data.azurerm_key_vault.cnp_vault.id
}

data "azurerm_key_vault" "soc_vault" {
  provider = azurerm.soc

  name                = var.soc_vault_name
  resource_group_name = var.soc_vault_rg
}

# Splunk UF
data "azurerm_key_vault_secret" "splunk_username" {
  provider = azurerm.soc

  name         = var.splunk_username_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}

data "azurerm_key_vault_secret" "splunk_password" {
  provider = azurerm.soc

  name         = var.splunk_password_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}

data "azurerm_key_vault_secret" "splunk_pass4symmkey" {
  provider = azurerm.soc

  name         = var.splunk_pass4symmkey_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}

# Tenable
data "azurerm_key_vault_secret" "nessus_agent_key" {
  provider = azurerm.soc

  name         = var.nessus_key_secret
  key_vault_id = data.azurerm_key_vault.soc_vault.id
}
