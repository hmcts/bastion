module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = "uksouth"
  resource_group_name = "rdo-mgmt-bastion-sbox-rg"
  vnet_name           = "rdo-mgmt-bastion-sbox-vnet"
  vnet_address_space  = ["10.200.100.0/24"]
  subnet_name         = "rdo-mgmt-bastion-sbox-subnet"
  subnet_address      = "10.200.100.0/24"
  keyvault_name       = "rdo-mgmt-bastion-sbox-kv"
  environment         = "sbox"
}