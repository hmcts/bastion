module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = "uksouth"
  resource_group_name = "bastion-test-rg"
  vnet_name           = "bastion-test-vnet"
  vnet_address_space  = ["10.20.20.64/27"]
  subnet_name         = "bastion-test-subnet"
  subnet_address      = "10.20.20.64/27"
  keyvault_name       = "bastion-test-kv"
  environment         = "test"
}