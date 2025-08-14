terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = ""
  }
  required_providers {
    azurerm = "~> 4.40.0"
  }
}

provider "azurerm" {
  version = "4.40.0"
  features {}
}
