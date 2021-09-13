module "bastion-prod" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_id            = local.image_id
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-prod"
  disk_size           = "1000"
  storage_type        = "StandardSSD_LRS"
  create_disks        = true
  install_splunk_uf   = false
}

module "bastion-secops" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_id            = local.image_id
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-secops-prod"
  install_splunk_uf   = false
}
