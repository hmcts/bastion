output "resource_group" {
  description = "The resource group name that contains the bastion host"
  value       = azurerm_resource_group.bastion
}

output "subnet" {
  description = "The subnet that contains the bastion host"
  value       = azurerm_subnet.bastion
}