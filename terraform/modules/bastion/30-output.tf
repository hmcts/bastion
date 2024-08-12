output "virtual_machine" {
  description = "The bastion virtual machine"
  value       = azurerm_linux_virtual_machine.bastion
}

output "ctags" {
  value = module.ctags
}