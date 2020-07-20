provider "azurerm" {
  version = ">= 2.17.0"
  features {}
  skip_provider_registration = "true"
  alias                      = "bastion"
}