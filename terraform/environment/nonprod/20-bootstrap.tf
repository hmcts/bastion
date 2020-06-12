module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = "uksouth"
  resource_group_name = "bastion-nonprod-rg"
  vnet_name           = "bastion-nonprod-vnet"
  vnet_address_space  = ["10.20.20.32/27"]
  subnet_name         = "bastion-nonprod-subnet"
  subnet_address      = "10.20.20.32/27"
  keyvault_name       = "bastion-nonprod-kv"
  environment         = "nonprod"
}