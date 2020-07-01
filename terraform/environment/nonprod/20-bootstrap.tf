module "bootstrap" {
  source              = "../../modules/bootstrap/"
  location            = local.location
  environment         = local.environment
  resource_group_name = "bastion-${local.environment}-rg"
  vnet_name           = "bastion-${local.environment}-vnet"
  keyvault_name       = "bastion-${local.environment}-kv"
  subnet_name         = "bastion"
  subnet_address      = local.subnet
  vnet_address_space  = [local.subnet]
}