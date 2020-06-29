variable "bastion_vnet_name" {
  description = "The user group name used to assign user login rights to the bastion host"
  type        = string
}

variable "bastion_vnet_resource_group" {
  description = "The resource group name of the bastion host.  Used for role assignment"
  type        = string
}

variable "bastion_vnet_id" {
  description = "The admin group name used to assign admin login rights to the bastion host"
  type        = string
}

variable "hub_vnet_resource_group" {
  description = "The resource group name of the bastion host.  Used for role assignment"
  type        = string
}

variable "hub_vnet_name" {
  description = "The resource group name of the bastion host.  Used for role assignment"
  type        = string
}

variable "hub_vnet_id" {
  description = "The admin group name used to assign admin login rights to the bastion host"
  type        = string
}