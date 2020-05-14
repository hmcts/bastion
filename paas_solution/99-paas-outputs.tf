#--------------------------------------------------------------
# Outputs
#--------------------------------------------------------------

output dns_name {
  value = azurerm_bastion_host.bastion_host.dns_name
}

output public_ip_address {
  value = azurerm_public_ip.bastion_pip.ip_address
}