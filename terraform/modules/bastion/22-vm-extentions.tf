resource "azurerm_virtual_machine_extension" "bastion_aad" {
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.bastion.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "customscript" {
  name                 = "formatdisks"
  virtual_machine_id   = azurerm_linux_virtual_machine.bastion.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  protected_settings   = local.backend_config_json
  depends_on           = [azurerm_virtual_machine_data_disk_attachment.diskattach]

}

module "splunk-uf" {
  count  = var.install_splunk_uf ? 1 : 0
  source = "git::https://github.com/hmcts/terraform-module-splunk-universal-forwarder.git?ref=master"

  auto_upgrade_minor_version = false
  virtual_machine_type       = "vm"
  virtual_machine_id         = azurerm_linux_virtual_machine.bastion.id
  splunk_username            = data.azurerm_key_vault_secret.splunk_username[0].value
  splunk_password            = data.azurerm_key_vault_secret.splunk_password[0].value
  splunk_pass4symmkey        = data.azurerm_key_vault_secret.splunk_pass4symmkey[0].value
  type_handler_version       = "3.0"
}
