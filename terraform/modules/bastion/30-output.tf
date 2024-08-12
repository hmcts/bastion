output "virtual_machine" {
  description = "The bastion virtual machine"
  value       = azurerm_linux_virtual_machine.bastion
}

output "merged_tags" {
  value = local.merged_tags
}