terraform {
  backend "azurerm" {
  storage_account_name    = "__bastion_sa__"
    container_name        = "__bastion_name__"
    key                   = "__bastion_name__/terraform.tfstate"
	  access_key            = "__bastion_sk__"
  }
}

data "azurerm_resource_group" "bastion_rg" {
  name = "__bastion_rg__"
}

data "azurerm_key_vault_secret" "admin-pass-kvs" {
name = "admin-password"
vault_uri = "https://__bastion_name__-kvs.vault.azure.net/"
}

data "azurerm_key_vault_secret" "admin-user-kvs" {
name = "admin-username"
vault_uri = "https://__bastion_name__-kvs.vault.azure.net/"
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "bastion_subnet"
  virtual_network_name = "${azurerm_virtual_network.bastion_vnet.name}"
  resource_group_name  = "__bastion_rg__"
  address_prefix       = "10.97.101.0/28"
}

resource "azurerm_virtual_network" "bastion_vnet" {
  address_space = ["10.97.101.0/28"]
  location = "__bastion_location__"
  name = "__bastion_name__-vn"
  resource_group_name = "__bastion_rg__"
}

resource "azurerm_network_interface" "bastion_nic" {
  name                      = "${var.bastion_vm_name}-${format("%02d",count.index)}-nic"
  location                  = "__bastion_location__"
  resource_group_name       = "__bastion_rg__"
  count                     = "${var.bastion_vm_count}"

  ip_configuration {
    name                          = "${var.bastion_vm_name}-${format("%02d",count.index)}-ip"
    subnet_id                     = "${azurerm_subnet.bastion_subnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.bastion_public_ip.*.id[count.index]}"
  }
}

resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "${var.bastion_vm_name}-${format("%02d",count.index)}-pip"
  location            = "__bastion_location__"
  resource_group_name = "__bastion_rg__"
  public_ip_address_allocation   = "static"
  count               = "${var.bastion_vm_count}"
}

resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "__bastion_name__-nsg"
  location            = "__bastion_location__"
  resource_group_name = "__bastion_rg__"
}

resource "azurerm_network_security_rule" "bastion_nsg_rule_ssh" {
  name                        = "SSH-in"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "__bastion_rg__"
  network_security_group_name = "${azurerm_network_security_group.bastion_nsg.name}" 
}

resource "azurerm_virtual_machine" "bastion_vm" {
  name                         = "${var.bastion_vm_name}-${format("%02d",count.index)}"
  location                     = "__bastion_location__"
  resource_group_name          = "__bastion_rg__" 
  network_interface_ids        = ["${azurerm_network_interface.bastion_nic.*.id[count.index]}"]
  vm_size                      = "Standard_B1s"
  count                        = "${var.bastion_vm_count}"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.bastion_vm_name}-${format("%02d",count.index)}-os"    
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  
  os_profile {
    computer_name      = "${var.bastion_vm_name}-${format("%02d",count.index)}" 
    admin_username     = "${data.azurerm_key_vault_secret.admin-user-kvs.value}"
    admin_password     = "${data.azurerm_key_vault_secret.admin-pass-kvs.value}"
  }
 os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${data.azurerm_key_vault_secret.admin-user-kvs.value}/.ssh/authorized_keys"
      key_data = "${file("${var.ssh_key}")}"
    }
  }

  provisioner "remote-exec" {
      inline = [
        "mkdir ~/ansible"
      ]
        connection {
      type     = "ssh"
      user     = "${data.azurerm_key_vault_secret.admin-user-kvs.value}"
      password = "${data.azurerm_key_vault_secret.admin-pass-kvs.value}"
  }
  }

    tags {
    environment = "rdo-bastion"
  }
  
}

resource "azurerm_virtual_machine_extension" "ansible_extension" {
  name                 = "Ansible-Agent-Install"
  location             = "__bastion_location__"
  resource_group_name  = "__bastion_rg__"
  virtual_machine_name = "${azurerm_virtual_machine.bastion_vm.name}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "sudo apt-get install -y software-properties-common",
        "commandToExecute": "sudo apt-add-repository --yes --update ppa:ansible/ansible",
        "commandToExecute": "sudo apt-get install -y ansible"      
    }
SETTINGS
}


resource "null_resource" "ansible-runs" {
    triggers = {
      always_run = "${timestamp()}"
    }

    depends_on = [
        "azurerm_public_ip.bastion_public_ip",
        "azurerm_virtual_machine_extension.ansible_extension",
        "azurerm_virtual_machine.bastion_vm"
    ]

  provisioner "file" {
    source      = "../ansible/"
    destination = "~/ansible/"
  
    connection {
      type     = "ssh"
      user     = "${data.azurerm_key_vault_secret.admin-user-kvs.value}"
      password = "${data.azurerm_key_vault_secret.admin-pass-kvs.value}"
      host     = "${azurerm_public_ip.bastion_public_ip.ip_address}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-galaxy install -r ~/ansible/requirements.yml",
      "ansible-playbook ~/ansible/playbooks/playbook.yml"
    ]

    connection {
      type     = "ssh"
      user     = "${data.azurerm_key_vault_secret.admin-user-kvs.value}"
      password = "${data.azurerm_key_vault_secret.admin-pass-kvs.value}"
      host     = "${azurerm_public_ip.bastion_public_ip.ip_address}"
    }
  }
}
