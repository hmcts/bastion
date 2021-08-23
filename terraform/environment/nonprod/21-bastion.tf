module "bastion-dev" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_id            = local.image_id
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-dev-nonprod"
  public_key          = "bastion-dev-nonprod.pub"
}

module "bastion-nonprod" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_id            = local.image_id
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-nonprod"
  public_key          = "bastion-nonprod.pub"
  disk_name           = "bastion-nonprod-datadisk"
  disk_size           = "1000"
  storage_type        = "StandardSSD_LRS"
  create_disks        = true
}