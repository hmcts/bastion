provider "azurerm" {
  version = ">= 2.17.0"
  features {}
  skip_provider_registration = "true"
}

provider "azurerm" {
  alias = "soc"
  features {}
  subscription_id = "8ae5b3b6-0b12-4888-b894-4cec33c92292"
}

provider "azurerm" {
  alias           = "shared_image_gallery"
  subscription_id = "2b1afc19-5ca9-4796-a56f-574a58670244"
}
