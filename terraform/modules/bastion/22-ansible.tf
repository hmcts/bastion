
# resource "azurerm_virtual_machine_extension" "ansible_extension" {
#   name                              = "Ansible-Agent-Install"
#   count                             = var.virtual_machine_count
#   virtual_machine_id                = element(azurerm_virtual_machine.bastion_vm.*.id, count.index)
#   publisher                         = "Microsoft.Azure.Extensions"
#   type                              = "CustomScript"
#   type_handler_version              = "2.0"

#   settings = <<SETTINGS
#     {
#         "commandToExecute": "sudo apt-get install -y software-properties-common",
#         "commandToExecute": "sudo apt-add-repository --yes --update ppa:ansible/ansible",
#         "commandToExecute": "sudo apt-get install -y ansible"      
#     }
# SETTINGS
# }

# resource "azurerm_virtual_machine_extension" "AADLoginForLinux" {
#     name                              = "AADLoginForLinux"
#     count                             = var.virtual_machine_count
#     virtual_machine_id                = element(azurerm_virtual_machine.bastion_vm.*.id, count.index)

#     publisher                         = "Microsoft.Azure.ActiveDirectory.LinuxSSH"
#     type                              = "AADLoginForLinux"
#     type_handler_version              = "1.0"
#     auto_upgrade_minor_version        = true
# }

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

