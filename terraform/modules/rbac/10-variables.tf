variable "bastion_name" {
  description = "Name of the bastion host"
  type        = string
}

variable "role_def_assignable_scopes" {
  description = "A list of subscriptions that the role definition will be assigned to"
  type        = list(string)
}

variable "role_assignment_scope" {
  description = "The resource where the role definition will be applied"
  type        = string
}

variable "bastion_admin_object_id" {
  description = "The object ID of the user or group that will be granted admin login access to the bastion host"
  type        = list(string)
}

variable "bastion_user_object_id" {
  description = "The object ID of the user or group that will be granted user login access to the bastion host"
  type        = list(string)
}