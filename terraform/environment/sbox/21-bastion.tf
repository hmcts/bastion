module "bastion" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_id            = local.image_id
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-dev-sbox"
  public_key          = "bastion-dev-sbox.pub"
}

module "bastion" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_id            = local.image_id
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-sbox"
  public_key          = "bastion-sbox.pub"
  disk_name           = "bastion-sbox-datadisk"
  disk_size           = "100"
  storage_type        = "StandardSSD_LRS"
}