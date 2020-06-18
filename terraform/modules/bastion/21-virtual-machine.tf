resource "azurerm_linux_virtual_machine" "bastion" {
  name                = var.bastion_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.common_tags
  size                = "Standard_B1s"
  admin_username      = var.bastion_username
  network_interface_ids = [
    azurerm_network_interface.bastion.id,
  ]

  admin_ssh_key {
    username   = var.bastion_username
    public_key = file("../../environment/${var.environment}/${var.public_key}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}