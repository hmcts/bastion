terraform {
  required_version = ">= 0.12.0"

  backend "azurerm" {
  }
}


provider "azurerm" {
  skip_provider_registration = "true"
  features {}

}
