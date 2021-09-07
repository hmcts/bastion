provider "azurerm" {
  version = ">= 2.17.0"
  features {}
  skip_provider_registration = "true"
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}