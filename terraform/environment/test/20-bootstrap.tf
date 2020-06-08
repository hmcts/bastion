module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = "uksouth"
  resource_group_name = "bastion-test-rg"
  vnet_name           = "bastion-test-vnet"
  vnet_address_space  = ["10.200.103.0/24"]
  subnet_name         = "bastion-test-subnet"
  subnet_address      = "10.200.103.0/24"
  keyvault_name       = "bastion-test-kv"
  environment         = "test"
}