module "bastion-dev-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-dev-nonprod"
  bastion_resource_group          = "bastion-nonprod-rg"
  bastion_access_admin_group_name = "DTS Non-Production Bastion Access for Administrators"
  bastion_access_user_group_name  = "DTS Non-Production Bastion Access for Users"
  provider_sub_id                 = "b44eb479-9ae2-42e7-9c63-f3c599719b6f"
}