terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = ""
  }
  required_providers {
    azurerm = "~> 3.117.0"
  }
}

provider "azurerm" {
  version = "3.117.1"
  features {}
}
