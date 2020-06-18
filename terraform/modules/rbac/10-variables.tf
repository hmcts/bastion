variable "role_assignment_scope" {
  description = "The object ID of the bastion host, where roles will be assigned"
  type        = string
}

variable "bastion_admin_group_object_id" {
  description = "The admin group object ID used to assign admin login rights to the bastion host"
  type        = string
}

variable "bastion_user_group_object_id" {
  description = "The user group object ID used to assign user login rights to the bastion host"
  type        = string
}