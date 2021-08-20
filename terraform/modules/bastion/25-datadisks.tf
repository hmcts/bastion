resource "azurerm_managed_disk" "disk" {
  name                 = var.disk_name
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.storage_type
  create_option        = "Empty"
  disk_size_gb         = var.disk_size
  tags                 = local.common_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "diskattach" {
  managed_disk_id    = azurerm_managed_disk.disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.bastion.id
  lun                = 0
  caching            = "ReadWrite"
}