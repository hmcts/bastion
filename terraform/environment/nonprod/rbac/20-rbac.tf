module "bastion-dev-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-dev-nonprod"
  bastion_resource_group          = "bastion-dev-rg"
  bastion_access_admin_group_name = "DTS Non-Production Bastion Access for Administrators"
  bastion_access_user_group_name  = "DTS Non-Production Bastion Access for Users"
}