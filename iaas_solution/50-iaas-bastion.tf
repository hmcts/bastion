variable "bastion_infra_rg" {}
variable "bastion_infra_key_vault" {}

data "azurerm_resource_group" "bastion_infra_rg" {
    name = var.bastion_infra_rg
}

data "azurerm_key_vault" "bastion_infra_keyvault" {
  name                = var.bastion_infra_key_vault
  resource_group_name = data.azurerm_resource_group.bastion_infra_rg.name
}

data "azurerm_key_vault_secret" "admin-password" {
  name = "admin-password"
  key_vault_id = data.azurerm_key_vault.bastion_infra_keyvault.id
}

data "azurerm_key_vault_secret" "admin-username" {
  name = "admin-username"
  key_vault_id = data.azurerm_key_vault.bastion_infra_keyvault.id
}

data "azurerm_key_vault_secret" "ssh-public-key" {
  name = "ssh-public-key"
  key_vault_id = data.azurerm_key_vault.bastion_infra_keyvault.id
}

resource "azurerm_virtual_machine" "bastion_vm" {
  name                            = "${var.virtual_machine_name}-${format("%02d",count.index)}"
  resource_group_name             = azurerm_resource_group.bastion_resource_group.name
  location                        = azurerm_resource_group.bastion_resource_group.location

  network_interface_ids           = [
    element(
      azurerm_network_interface.bastion_nic.*.id,
      count.index,
    ),
  ]
  vm_size                         = "Standard_B1s"
  count                           = var.virtual_machine_count

  storage_image_reference {
    publisher                     = "Canonical"
    offer                         = "UbuntuServer"
    sku                           = "18.04-LTS"
    version                       = "latest"
  }

  storage_os_disk {
    name                          = "${var.virtual_machine_name}-${format("%02d",count.index)}-os"    
    caching                       = "ReadWrite"
    create_option                 = "FromImage"
    managed_disk_type             = "Standard_LRS"
  }
  
  os_profile {
    computer_name                 = "${var.virtual_machine_name}-${format("%02d",count.index)}"
    admin_username                = data.azurerm_key_vault_secret.admin-username.value
    admin_password                = data.azurerm_key_vault_secret.admin-password.value
  }
 os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path                        = "/home/${data.azurerm_key_vault_secret.admin-username.value}/.ssh/authorized_keys"
      key_data                    = data.azurerm_key_vault_secret.ssh-public-key.value
    }
  }

  tags                              = var.tags
}

resource "azurerm_virtual_machine_extension" "ansible_extension" {
  name                              = "Ansible-Agent-Install"
  count                             = var.virtual_machine_count
  virtual_machine_id                = element(azurerm_virtual_machine.bastion_vm.*.id, count.index)
  publisher                         = "Microsoft.Azure.Extensions"
  type                              = "CustomScript"
  type_handler_version              = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get install -y software-properties-common",
        "commandToExecute": "sudo apt-add-repository --yes --update ppa:ansible/ansible",
        "commandToExecute": "sudo apt-get install -y ansible"      
    }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "AADLoginForLinux" {
    name                              = "AADLoginForLinux"
    count                             = var.virtual_machine_count
    virtual_machine_id                = element(azurerm_virtual_machine.bastion_vm.*.id, count.index)

    publisher                         = "Microsoft.Azure.ActiveDirectory.LinuxSSH"
    type                              = "AADLoginForLinux"
    type_handler_version              = "1.0"
    auto_upgrade_minor_version        = true
}


# resource "null_resource" "ansible-runs" {
#     triggers = {
#       always_run = timestamp()
#     }

#     depends_on = [
#         azurerm_public_ip.bastion_public_ip,
#         azurerm_virtual_machine_extension.ansible_extension,
#         azurerm_virtual_machine.bastion_vm
#     ]

#   provisioner "remote-exec" {
#       inline = [
#         "mkdir ~/ansible"
#       ]
#     connection {
#       type                          = "ssh"
#       user                          = data.azurerm_key_vault_secret.admin-username.value
#       password                      = data.azurerm_key_vault_secret.admin-password.value
#       host                          = azurerm_public_ip.bastion_public_ip.*.ip_address
#       #azurerm_public_ip.bastion_public_ip.*.ip_address[count.index]
#       # azurerm_network_interface.bastion_nic.*.private_ip_address[count.index]
#   }
#   }

#   provisioner "file" {
#     source      = "${path.module}/ansible/"
#     destination = "~/ansible/"
  
#     connection {
#       type                        = "ssh"
#       user                        = data.azurerm_key_vault_secret.admin-username.value
#       password                    = data.azurerm_key_vault_secret.admin-password.value
#       host                        = azurerm_public_ip.bastion_public_ip.*.ip_address
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "ansible-galaxy install -r ~/ansible/requirements.yml",
#       "ansible-playbook ~/ansible/playbooks/playbook.yml"
#     ]

#     connection {
#       type                          = "ssh"
#       user                          = data.azurerm_key_vault_secret.admin-username.value
#       password                      = data.azurerm_key_vault_secret.admin-password.value
#       host                          = azurerm_public_ip.bastion_public_ip.*.ip_address
#     }
#   }
# }

