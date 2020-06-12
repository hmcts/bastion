module "bastion_devops" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-devops-sbox"
  environment         = "sbox"
  public_key          = "bastion-devops-sbox.pub"
}