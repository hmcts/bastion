provider "azurerm" {
  version = ">= 2.0.0"
  features {}
}

provider "azurerm" {
  subscription_id = "fb084706-583f-4c9a-bdab-949aac66ba5c"
  alias           = "hub-nonprod-intsvc"
  features {}
}

data "azurerm_virtual_network" "hub" {
  provider = azurerm.hub-nonprod-intsvc

  name                = "hmcts-hub-nonprodi"
  resource_group_name = "hmcts-hub-nonprodi"
}

resource "azurerm_virtual_network_peering" "bastion-to-hub" {
  name                      = "${module.bootstrap.vnet.name}-to-hub"
  resource_group_name       = module.bootstrap.vnet.resource_group_name
  virtual_network_name      = module.bootstrap.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.hub.id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}

resource "azurerm_virtual_network_peering" "hub-to-bastion" {
  provider = azurerm.hub-nonprod-intsvc

  name                      = "hub-to-${module.bootstrap.vnet.name}"
  resource_group_name       = data.azurerm_virtual_network.hub.resource_group_name
  virtual_network_name      = data.azurerm_virtual_network.hub.name
  remote_virtual_network_id = module.bootstrap.vnet.id

  allow_virtual_network_access = "true"
  allow_forwarded_traffic      = "true"
}