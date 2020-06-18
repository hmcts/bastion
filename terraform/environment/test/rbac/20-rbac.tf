module "bastion-devops-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-devops-test"
  bastion_resource_group          = "bastion-test-rg"
  bastion_access_admin_group_name = "DTS Production Bastion Access for Administrators (DevOps)"
  bastion_access_user_group_name  = "DTS Production Bastion Access for Users (DevOps)"
}