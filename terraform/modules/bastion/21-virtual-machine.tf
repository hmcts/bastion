data "azurerm_shared_image_version" "shared_image_version" {
  provider            = azurerm.shared_image_gallery
  name                = var.image_version
  image_name          = "bastion-ubuntu"
  gallery_name        = "hmcts"
  resource_group_name = "hmcts-image-gallery-rg"
}

resource "azurerm_linux_virtual_machine" "bastion" {
  name                = var.bastion_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = module.ctags.common_tags
  size                = var.environment == "sbox" ? "Standard_D2ds_v5" : "Standard_D4ds_v5"
  admin_username      = var.bastion_username
  network_interface_ids = [
    azurerm_network_interface.bastion.id,
  ]

  admin_ssh_key {
    username   = var.bastion_username
    public_key = tls_private_key.bastion_ssh_key.public_key_openssh
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_shared_image_version.shared_image_version.id
}
