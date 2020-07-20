provider "azurerm" {
  version = ">= 2.17.0"
  features {}
  skip_provider_registration = "true"
  alias                      = "bastion"
}

provider "azurerm" {
  version = ">= 2.17.0"
  features {}
  subscription_id = var.vpn_subscription_id
  alias           = "vpn"
}