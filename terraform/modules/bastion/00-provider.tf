provider "azurerm" {
  version = ">= 3.4.0"
  features {}
  skip_provider_registration = "true"
}

provider "azurerm" {
  alias                      = "soc"
  skip_provider_registration = "true"
  features {}
  subscription_id = "8ae5b3b6-0b12-4888-b894-4cec33c92292"
}

provider "azurerm" {
  alias                      = "shared_image_gallery"
  skip_provider_registration = "true"
  features {}
  subscription_id = "2b1afc19-5ca9-4796-a56f-574a58670244"
}

provider "azurerm" {
  alias                      = "cnp"
  skip_provider_registration = "true"
  features {}
  subscription_id = var.cnp_vault_sub
}

provider "azurerm" {
  alias                      = "dcr"
  skip_provider_registration = "true"
  features {}
  subscription_id = var.environment == "prod" || var.environment == "production" ? "8999dec3-0104-4a27-94ee-6588559729d1" : var.environment == "sbox" || var.environment == "sandbox" ? "bf308a5c-0624-4334-8ff8-8dca9fd43783" : "1c4f0704-a29e-403d-b719-b90c34ef14c9"

}
