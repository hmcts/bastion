terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = "b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac"
  }
  required_providers {
    azurerm = "~> 3.117.0"
  }
}

provider "azurerm" {
  version = "3.117.1"
  features {}
  skip_provider_registration = "true"
}

provider "azurerm" {
  version = ">= 3.4.0"
  features {}
  subscription_id            = local.hub_subscription_id
  alias                      = "hub"
  skip_provider_registration = "true"
}
