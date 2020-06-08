module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = "uksouth"
  resource_group_name = "bastion-nonprod-rg"
  vnet_name           = "bastion-nonprod-vnet"
  vnet_address_space  = ["10.200.101.0/24"]
  subnet_name         = "bastion-nonprod-subnet"
  subnet_address      = "10.200.101.0/24"
  keyvault_name       = "bastion-nonprod-kv"
  environment         = "nonprod"
}