module "bastion-devops-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-devops-test"
  bastion_resource_group          = "bastion-test-rg"
  bastion_access_admin_group_name = "DTS Non-Production Bastion Access for Administrators"
  bastion_access_user_group_name  = "DTS Non-Production Bastion Access for Users"
  bastion_subscription_id         = "d7b54c7f-c2c9-41ee-930d-7056ebbb5bde"
  aad_role_def_id_admin           = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/1c0163c0-47e6-4577-8991-ea5c82e286e4"
  aad_role_def_id_user            = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/fb879df8-f326-4884-b1cf-06f3ad86be52"
}