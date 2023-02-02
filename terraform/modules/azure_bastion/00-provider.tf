
provider "azurerm" {
  version = ">= 3.4.0"
  features {}
  subscription_id = var.hub_subscription_id
  alias           = "hub"
}
