output "resource_group" {
  description = "The resource group name that contains the bastion host"
  value       = azurerm_resource_group.bastion
}

output "vnet" {
  description = "The virtual network that contains the bastion host secrets"
  value       = azurerm_virtual_network.bastion
}

output "subnet" {
  description = "The subnet that contains the bastion host"
  value       = azurerm_subnet.bastion
}

output "keyvault" {
  description = "The keyvault that contains the bastion host secrets"
  value       = azurerm_key_vault.bastion
}