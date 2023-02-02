# Create AzureBastionSubnet
resource "azurerm_subnet" "azure_bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.azbastion_subnet_address
}



resource "azurerm_public_ip" "p_ip_bastion" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.allocation_method
  sku                 = var.public_ip_sku
  tags                = module.ctags.common_tags
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.bastion_sku
  tunneling_enabled   = var.tunneling_enabled
  tags                = module.ctags.common_tags

  ip_configuration {
    name                 = var.ip_config_name
    subnet_id            = azurerm_subnet.azure_bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.p_ip_bastion.id
  }
}
