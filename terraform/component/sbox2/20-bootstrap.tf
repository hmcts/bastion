module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = "uksouth"
  resource_group_name = "bastion-sbox2-rg"
  vnet_name           = "bastion-sbox2-vnet"
  vnet_address_space  = ["10.200.101.0/24"]
  subnet_name         = "bastion-sbox2-subnet"
  subnet_address      = "10.200.101.0/24"
  keyvault_name       = "bastion-sbox2-kv"
  environment         = "sbox"
}