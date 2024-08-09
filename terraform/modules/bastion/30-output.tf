output "virtual_machine" {
  description = "The bastion virtual machine"
  value       = azurerm_linux_virtual_machine.bastion
}

output "common_tags" {
  description = "Returns a mapping of tags to assign."
  value = module.ctags.common_tags
}