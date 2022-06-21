provider "azurerm" {
  version = ">= 3.4.0"
  features {}
  skip_provider_registration = "true"
}

provider "azurerm" {
  version = ">= 3.4.0"
  features {}
  subscription_id = var.bastion_subscription_id
  alias           = "bastion"
}

provider "azuread" {
  version = "0.11"
}
