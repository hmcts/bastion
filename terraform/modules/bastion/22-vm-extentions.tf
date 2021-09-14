resource "azurerm_virtual_machine_extension" "bastion_aad" {
  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.bastion.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "customscript" {
  name                 = "ConfigureBastion"
  virtual_machine_id   = azurerm_linux_virtual_machine.bastion.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  protected_settings   = <<PROTECTED_SETTINGS
    {
      "fileUris": ["${local.script_uri}"],
      "commandToExecute": "${local.cse_script}"
    }
    PROTECTED_SETTINGS
  depends_on           = [azurerm_virtual_machine_data_disk_attachment.diskattach]

}
