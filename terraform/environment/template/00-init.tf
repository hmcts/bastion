terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = ""
  }
  required_providers {
    azurerm = "~> 3.84.0"
  }
}

provider "azurerm" {
  version = "3.84.0"
  features {}
}
