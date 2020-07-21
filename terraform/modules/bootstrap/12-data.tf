data "azurerm_client_config" "current" {}

data "azurerm_lb" "hub_palo" {
  provider = azurerm.hub

  name                = var.hub_lb_name
  resource_group_name = var.hub_lb_resource_group
}