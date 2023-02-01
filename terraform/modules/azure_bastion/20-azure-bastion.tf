resource "azurerm_public_ip" "bastion_ip" {
  count               = var.az_bastion_subnet == null ? 0 : 1
  name                = "azure-bastion-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.bastionrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = module.ctags.common_tags
}

resource "azurerm_bastion_host" "bastion" {
  count               = var.az_bastion_subnet == null ? 0 : 1
  name                = "azure-bastion-${var.env}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.bastionrg.name
  sku                 = "Standard"
  tunneling_enabled   = true
  tags                = module.ctags.common_tags

  ip_configuration {
    name                 = "ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion_ip[0].id
  }
}
