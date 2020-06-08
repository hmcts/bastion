
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

