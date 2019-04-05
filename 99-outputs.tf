

output "bastion_priv_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${azurerm_network_interface.bastion_nic.*.private_ip_address}"
}

output "bastion_pub_ip" {
  description = "public ip addresses of the vm nics"
  value       = "${azurerm_public_ip.bastion_public_ip.*.ip_address}"
}

output "bastion_hostname" {
  description = "public ip addresses of the vm nics"
  value       = "${azurerm_virtual_machine.bastion_vm.*.name}"
}


