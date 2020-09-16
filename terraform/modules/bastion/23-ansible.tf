
resource "null_resource" "ansible-runs" {
  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    azurerm_network_interface.bastion,
    azurerm_virtual_machine_extension.bastion_ansible,
    azurerm_virtual_machine.bastion
  ]

  provisioner "remote-exec" {
    inline = [
      "mkdir ~/ansible"
    ]
    connection {
      type     = "ssh"
      user     = data.azurerm_key_vault_secret.admin-username.value
      password = data.azurerm_key_vault_secret.admin-password.value
      host     = azurerm_network_interface.bastion_nic.*.private_ip_address[count.index]
    }
  }

  provisioner "file" {
    source      = "${path.module}/ansible/"
    destination = "~/ansible/"

    connection {
      type     = "ssh"
      user     = data.azurerm_key_vault_secret.admin-username.value
      password = data.azurerm_key_vault_secret.admin-password.value
      host     = azurerm_network_interface.bastion_nic.*.private_ip_address[count.index]
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && apt-get install ansible",
      "ansible-galaxy install -r ~/ansible/requirements.yml",
      "ansible-playbook ~/ansible/playbooks/playbook.yml"
    ]

    connection {
      type     = "ssh"
      user     = data.azurerm_key_vault_secret.admin-username.value
      password = data.azurerm_key_vault_secret.admin-password.value
      host     = azurerm_network_interface.bastion_nic.*.private_ip_address[count.index]
    }
  }
}

