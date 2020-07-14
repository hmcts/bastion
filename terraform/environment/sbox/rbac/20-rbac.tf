module "bastion-deveops-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-dev-sbox"
  bastion_resource_group          = "bastion-sbox-rg"
  bastion_access_admin_group_name = "DTS Non-Production Bastion Access for Administrators"
  bastion_access_user_group_name  = "DTS Non-Production Bastion Access for Users"
  bastion_subscription_id         = "b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac"
  aad_role_def_id_admin           = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/1c0163c0-47e6-4577-8991-ea5c82e286e4"
  aad_role_def_id_user            = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/fb879df8-f326-4884-b1cf-06f3ad86be52"
}