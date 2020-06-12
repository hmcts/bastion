module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = "uksouth"
  resource_group_name = "bastion-prod-rg"
  vnet_name           = "bastion-prod-vnet"
  vnet_address_space  = ["10.20.20.0/27"]
  subnet_name         = "bastion-prod-subnet"
  subnet_address      = "10.20.20.0/27"
  keyvault_name       = "bastion-prod-kv"
  environment         = "prod"
}