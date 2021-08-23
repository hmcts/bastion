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
  disk_name           = "bastion-dev-nonprod-datadisk"
  disk_size           = "1000"
  storage_type        = "StandardSSD_LRS"
}