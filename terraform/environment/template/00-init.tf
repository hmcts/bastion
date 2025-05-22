terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = ""
  }
  required_providers {
    azurerm = "~> 4.30.0"
  }
}

provider "azurerm" {
  version = "4.30.0"
  features {}
}
