terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = "d7b54c7f-c2c9-41ee-930d-7056ebbb5bde"
  }
  required_providers {
    azurerm = "~> 4.54.0"
  }
}

provider "azurerm" {
  version = "4.54.0"
  features {}
}

provider "azuread" {
  version = "2.46"
  features {}
}
