terraform {
  required_version = ">= 0.12.25"
  backend "azurerm" {
    subscription_id = "b44eb479-9ae2-42e7-9c63-f3c599719b6f"
  }
  required_providers {
    azurerm = "~> 3.85.0"
  }
}

provider "azurerm" {
  version = "3.85.0"
  features {}
}

provider "azurerm" {
  version = ">= 3.4.0"
  features {}
  subscription_id = local.hub_subscription_id
  alias           = "hub"
}
provider "azurerm" {
  features {}
  subscription_id = "1baf5470-1c3e-40d3-a6f7-74bfbce4b348"
  alias           = "DTS-CFTPTL-INTSVC"
}
