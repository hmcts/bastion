terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = "b44eb479-9ae2-42e7-9c63-f3c599719b6f"
  }
  required_providers {
    azurerm = "~> 4.51.0"
  }
}

provider "azurerm" {
  version = "4.51.0"
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
