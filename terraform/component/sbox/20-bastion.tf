module "bastion-devops" {
  source              = "../../modules/bastion/"
  location            = "uksouth"
  resource_group_name = "rdo-mgmt-bastion-devops-rg"
  vnet_name           = "rdo-mgmt-bastion-devops-vnet"
  vnet_address_space  = ["10.200.100.0/24"]
  vnet_subnet_address = "10.200.100.0/24"
  bastion_name        = "rdo-mgmt-bastion-devops-sbox"
  environment         = "sbox"
}

module "bastion-dev" {
  source              = "../../modules/bastion/"
  location            = "uksouth"
  resource_group_name = "rdo-mgmt-bastion-dev-rg"
  vnet_name           = "rdo-mgmt-bastion-dev-vnet"
  vnet_address_space  = ["10.200.101.0/24"]
  vnet_subnet_address = "10.200.101.0/24"
  bastion_name        = "rdo-mgmt-bastion-dev-sbox"
  environment         = "sbox"
}