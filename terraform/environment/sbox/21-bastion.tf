module "bastion-sbox" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_id            = "1.0.1"
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-sbox"
  disk_size           = "100"
  storage_type        = "StandardSSD_LRS"
  create_disks        = true
  install_splunk_uf   = true
}
