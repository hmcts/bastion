
resource "azurerm_linux_virtual_machine" "bastion" {
  name                  = var.bastion_name
  resource_group_name   = azurerm_resource_group.bastion.name
  location              = azurerm_resource_group.bastion.location
  tags                  = local.common_tags

  size                  = "Standard_B1s"
  admin_username        = var.bastion_username
  network_interface_ids = [
    azurerm_network_interface.bastion.id,
  ]

  admin_ssh_key {
    username   = var.bastion_username
    public_key = file("../../component/${var.environment}/id_rsa_bastion.pub")
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