provider "azurerm" {
  version = ">= 2.17.0"
  features {}
  skip_provider_registration = "true"
}

provider "azurerm" {
  version = ">= 2.17.0"
  features {}
  subscription_id = var.hub_subscription_id
  alias           = "hub"
}