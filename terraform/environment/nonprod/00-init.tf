terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {}
  required_providers {
    azurerm = "~> 2.0.0"
  }
}