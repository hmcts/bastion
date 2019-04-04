terraform {

  required_version = ">= 0.11" 
  backend "azurerm" {
  storage_account_name    = "__bastion_sa__"
    container_name        = "__bastion_name__"
    key                   = "__bastion_name__/terraform.tfstate"
	  access_key            = "__bastion_sk__"
  }
}

providers {
  azurerm = "1.24"
}