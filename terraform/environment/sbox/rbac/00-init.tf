terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = "b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac"
  }
  required_providers {
    azurerm = "~> 3.85.0"
  }
}

provider "azurerm" {
  version = "3.85.0"
  features {}
}

provider "azuread" {
  version = "2.46"
  features {}
}
