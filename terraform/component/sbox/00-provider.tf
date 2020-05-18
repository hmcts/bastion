
terraform {
  required_version = ">= 0.12.25"
}

provider "azurerm" {
  version = "=2.0.0"
  features {}
  skip_provider_registration = "true"
}