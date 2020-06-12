module "bastion-dev" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-dev-nonprod"
  environment         = "nonprod"
  public_key          = "bastion-dev-nonprod.pub"
}