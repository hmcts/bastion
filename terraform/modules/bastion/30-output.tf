output "virtual_machine" {
  description = "The bastion virtual machine"
  value       = azurerm_linux_virtual_machine.bastion
}

output "merged_tags" {
  value = local.merged_tags
}

output "ctags_common_tags" {
  value = module.ctags.common_tags
}

output "auto_shutdown_common_tags" {
  value = local.auto_shutdown_common_tags
}