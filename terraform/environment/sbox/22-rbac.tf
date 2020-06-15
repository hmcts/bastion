module "rbac_bastion_devops" {
  source                     = "../../modules/rbac/"
  bastion_name               = module.bastion_devops.virtual_machine.name
  role_assignment_scope      = module.bastion_devops.virtual_machine.id
  role_def_assignable_scopes = ["/subscriptions/89678afe-decf-43ac-a878-64359bdbed56","/subscriptions/e9ae238a-841e-4469-bdb4-33cbaa9dac7d"]
  bastion_admin_object_id    = ["f76b6e44-1907-4831-973c-8c8c531de79b","e9758ffc-ded6-4a06-9e61-361cd771e8d6"]
  bastion_user_principal_id  = ["f76b6e44-1907-4831-973c-8c8c531de79b"]
}