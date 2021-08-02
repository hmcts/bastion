resource "azurerm_linux_virtual_machine" "bastion" {
  name                = var.bastion_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.common_tags
  size                = "Standard_D2ds_v4"
  admin_username      = var.bastion_username
  network_interface_ids = [
    azurerm_network_interface.bastion.id,
  ]

  admin_ssh_key {
    username   = var.bastion_username
    public_key = file("../../environment/${var.environment}/${var.public_key}")
  }
  
  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = var.image_id
}
