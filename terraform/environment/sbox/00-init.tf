terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = "b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac"
  }
  required_providers {
    azurerm = "~> 2.17.0"
  }
}

provider "azurerm" {
  version = "2.17.0"
  features {}
}

provider "azurerm" {
  alias  = "shared_image_gallery"
  subscription_id = "2b1afc19-5ca9-4796-a56f-574a58670244"
}