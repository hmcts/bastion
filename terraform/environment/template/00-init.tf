terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = ""
  }
  required_providers {
    azurerm = "~> 5.10.0"
  }
}

provider "azurerm" {
  version = "5.10.0"
  features {}
}
