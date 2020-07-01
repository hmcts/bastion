module "rbac_bastion-devops" {
  source                        = "../../../modules/rbac/"
  role_assignment_scope         = ""
  bastion_admin_group_object_id = ""
  bastion_user_group_object_id  = ""
}