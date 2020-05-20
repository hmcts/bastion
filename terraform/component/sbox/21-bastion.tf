
module "bastion-devops" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  bastion_name        = "rdo-mgmt-bastion-devops-sbox"
  environment         = "sbox"
}

module "bastion-dev" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  bastion_name        = "rdo-mgmt-bastion-dev-sbox"
  environment         = "sbox"
}