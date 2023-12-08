module "bastion-dev-rbac" {
  source                          = "../../../modules/rbac/"
  bastion_vm_name                 = "bastion-nonprod"
  bastion_resource_group          = "bastion-nonprod-rg"
  bastion_access_admin_group_name = "DTS Non-Production Bastion Access for Administrators"
  bastion_access_user_group_name  = "DTS Non-Production Bastion Access for Users"
  bastion_subscription_id         = "b44eb479-9ae2-42e7-9c63-f3c599719b6f"
  aad_role_def_id_admin           = "/subscriptions/b44eb479-9ae2-42e7-9c63-f3c599719b6f/providers/Microsoft.Authorization/roleDefinitions/1c0163c0-47e6-4577-8991-ea5c82e286e4"
  aad_role_def_id_user            = "/subscriptions/b44eb479-9ae2-42e7-9c63-f3c599719b6f/providers/Microsoft.Authorization/roleDefinitions/fb879df8-f326-4884-b1cf-06f3ad86be52"
  aad_workaround_users = [
    "aaefee8a-5409-4156-bcda-76171e1ca833",
    "ffb2cb96-d318-48c8-bfd4-b7d8c38743d8",
    "d64330dc-2970-4da8-adf8-beec5126c666",
    "cc2d6a5d-5e54-4d39-ba3a-01fc0da9545c"
  ]
}