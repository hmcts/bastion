module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = "uksouth"
  resource_group_name = "bastion-sbox-rg"
  vnet_name           = "bastion-sbox-vnet"
  vnet_address_space  = ["10.200.100.0/24"]
  subnet_name         = "bastion-sbox-subnet"
  subnet_address      = "10.200.100.0/24"
  keyvault_name       = "bastion-sbox-kv"
  environment         = "sbox"
}