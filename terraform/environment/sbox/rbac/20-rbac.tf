module "rbac_bastion-devops" {
  source                        = "../../../modules/rbac/"
  bastion_name                  = "bastion-devops-sbox"
  role_assignment_scope         = ""
  bastion_admin_group_object_id = ""
  bastion_user_group_object_id  = ""

  role_def_assignable_scopes = [
    "/subscriptions/89678afe-decf-43ac-a878-64359bdbed56",
    "/subscriptions/e9ae238a-841e-4469-bdb4-33cbaa9dac7d"
  ]
}