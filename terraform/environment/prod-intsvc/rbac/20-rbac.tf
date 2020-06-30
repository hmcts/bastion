module "bastion-devops-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-devops-prod"
  bastion_resource_group          = "bastion-prod-rg"
  bastion_access_admin_group_name = "DTS Production Bastion Access for Administrators (DevOps)"
  bastion_access_user_group_name  = "DTS Production Bastion Access for Users (DevOps)"
}

module "bastion-secops-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-secops-prod"
  bastion_resource_group          = "bastion-prod-rg"
  bastion_access_admin_group_name = "DTS Production Bastion Access for Administrators (SecOps)"
  bastion_access_user_group_name  = "DTS Production Bastion Access for Users (SecOps)"
}