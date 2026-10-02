terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = ""
  }
  required_providers {
    azurerm = "~> 5.8.0"
  }
}

provider "azurerm" {
  version = "5.8.0"
  features {}
}
