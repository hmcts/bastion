module "bastion-nonprod" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_version       = local.image_version
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-nonprod"
  disk_size           = "1000"
  storage_type        = "StandardSSD_LRS"
  create_disks        = true
  install_splunk_uf   = true
}
