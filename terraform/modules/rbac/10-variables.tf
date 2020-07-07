variable "bastion_vm_name" {
  description = "The virtual machine name of the bastion host.  Used for role assignment"
  type        = string
}

variable "bastion_resource_group" {
  description = "The resource group name of the bastion host.  Used for role assignment"
  type        = string
}

variable "bastion_access_admin_group_name" {
  description = "The admin group name used to assign admin login rights to the bastion host"
  type        = string
}

variable "bastion_access_user_group_name" {
  description = "The user group name used to assign user login rights to the bastion host"
  type        = string
}

variable "provider_sub_id" {
  description = "The subscription ID of the bastion host"
  type        = string
}