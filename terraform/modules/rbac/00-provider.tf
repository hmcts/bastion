provider "azurerm" {
  version = ">= 2.0.0"
  features {}
  skip_provider_registration = "true"
}

provider "azurerm" {
  features {}
  subscription_id = var.provider_sub_id
  alias           = "bastion"
}