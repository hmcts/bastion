module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = "uksouth"
  resource_group_name = "bastion-sbox-rg"
  vnet_name           = "bastion-sbox-vnet"
  vnet_address_space  = ["10.20.20.96/27"]
  subnet_name         = "bastion-sbox-subnet"
  subnet_address      = "10.20.20.96/27"
  keyvault_name       = "bastion-sbox-kv"
  environment         = "sbox"
}