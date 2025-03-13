terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = "2b1afc19-5ca9-4796-a56f-574a58670244"
  }
  required_providers {
    azurerm = "~> 3.117.0"
  }
}

provider "azurerm" {
  version = "3.117.1"
  features {}
  skip_provider_registration = "true"
}

provider "azuread" {
  version = "2.46"
  features {}
}
