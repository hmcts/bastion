module "bastion-prod-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-prod"
  bastion_resource_group          = "bastion-prod-rg"
  bastion_access_admin_group_name = "DTS Production Bastion Access for Administrators (DevOps)"
  bastion_access_user_group_name  = "DTS Production Bastion Access for Users (DevOps)"
  bastion_subscription_id         = "2b1afc19-5ca9-4796-a56f-574a58670244"
  aad_role_def_id_admin           = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/1c0163c0-47e6-4577-8991-ea5c82e286e4"
  aad_role_def_id_user            = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/fb879df8-f326-4884-b1cf-06f3ad86be52"
}

module "bastion-secops-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-secops-prod"
  bastion_resource_group          = "bastion-prod-rg"
  bastion_access_admin_group_name = "DTS Production Bastion Access for Administrators (SecOps)"
  bastion_access_user_group_name  = "DTS Production Bastion Access for Users (SecOps)"
  bastion_subscription_id         = "2b1afc19-5ca9-4796-a56f-574a58670244"
  aad_role_def_id_admin           = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/1c0163c0-47e6-4577-8991-ea5c82e286e4"
  aad_role_def_id_user            = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/fb879df8-f326-4884-b1cf-06f3ad86be52"
}

module "bastion-devops-rbac" {
  source                          = "../../../modules/empty/"
  bastion_vm_name                 = "bastion-devops-prod"
  bastion_resource_group          = "bastion-prod-rg"
  bastion_access_admin_group_name = "DTS Production Bastion Access for Administrators (DevOps)"
  bastion_access_user_group_name  = "DTS Production Bastion Access for Users (DevOps)"
  bastion_subscription_id         = "2b1afc19-5ca9-4796-a56f-574a58670244"
  aad_role_def_id_admin           = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/1c0163c0-47e6-4577-8991-ea5c82e286e4"
  aad_role_def_id_user            = "/subscriptions/00b9a00a-20eb-4173-b7b6-468e00836a33/providers/Microsoft.Authorization/roleDefinitions/fb879df8-f326-4884-b1cf-06f3ad86be52"
}