terraform {
  required_version = "1.3.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.36.0"
    }
  }

  backend "azurerm" {}
}


provider "azurerm" {
  version = ">= 3.4.0"
  features {}
  subscription_id = var.hub_subscription_id
  alias           = "hub"
}
