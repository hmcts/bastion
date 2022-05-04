terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = "2b1afc19-5ca9-4796-a56f-574a58670244"
  }
  required_providers {
    azurerm = "~> 3.4.0"
  }
}

provider "azurerm" {
  version = "3.4.0"
  features {}
}

provider "azuread" {
  version = "0.10"
  features {}
}
