resource "azurerm_virtual_machine_extension" "bastion_aad" {
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.bastion.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = module.ctags.common_tags
}

module "virtual_machine_bootstrap" {
  providers = {
    azurerm     = azurerm
    azurerm.cnp = azurerm.cnp
    azurerm.soc = azurerm.soc
  }
  source      = local.vm_bootstrap_source
  common_tags = module.ctags.common_tags
  env         = var.environment == "prod" ? var.environment : "nonprod"
  # General
  os_type              = "Linux"
  virtual_machine_id   = azurerm_linux_virtual_machine.bastion.id
  virtual_machine_type = "vm"

  # Custom Script
  additional_script_path = "${path.module}/ConfigureBastion.sh"

  # Dynatrace OneAgent
  dynatrace_hostgroup = "Platform_Operation_Bastions"
  dynatrace_tenant_id = var.dynatrace_tenant_id
  dynatrace_token     = data.azurerm_key_vault_secret.token.value
  dynatrace_server    = var.dynatrace_server

  # Splunk UF
  splunk_username     = data.azurerm_key_vault_secret.splunk_username.value
  splunk_password     = data.azurerm_key_vault_secret.splunk_password.value
  splunk_pass4symmkey = data.azurerm_key_vault_secret.splunk_pass4symmkey.value

  # Tenable Nessus
  nessus_server = var.nessus_server
  nessus_key    = data.azurerm_key_vault_secret.nessus_agent_key.value
  nessus_groups = "Platform-Operation-Bastions"
}
