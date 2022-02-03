terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = "b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac"
  }
  required_providers {
    azurerm = "~> 2.17.0"
  }
}

provider "azurerm" {
  version = "2.17.0"
  features {}
}

provider "azurerm" {
  version = ">= 2.17.0"
  features {}
  subscription_id = local.hub_subscription_id
  alias           = "hub"
}