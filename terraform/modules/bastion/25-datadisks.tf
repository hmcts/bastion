resource "azurerm_managed_disk" "disk" {
  count                = var.create_disks ? 1 : 0
  name                 = "${var.bastion_name}-datadisk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.storage_type
  create_option        = "Empty"
  disk_size_gb         = var.disk_size
  tags                 = local.common_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "diskattach" {
  count              = var.create_disks ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.bastion.id
  lun                = 0
  caching            = "ReadWrite"
}