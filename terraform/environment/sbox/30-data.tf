data "azurerm_client_config" "current" {}

data "azurerm_lb" "hub_palo" {
  provider            = azurerm.hub
  name                = local.hub_lb_name
  resource_group_name = local.hub_lb_resource_group
}