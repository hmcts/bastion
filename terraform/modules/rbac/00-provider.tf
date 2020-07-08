provider "azurerm" {
  version = ">= 2.17.0"
  features {}
  skip_provider_registration = "true"
}

provider "azurerm" {
  features {}
  subscription_id = var.bastion_subscription_id
  alias           = "bastion"
}