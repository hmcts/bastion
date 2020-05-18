
variable "location" {
  description = "Azure resource location"
  default     = "uksouth"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name that contains the bastion host"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name that contains the bastion host"
  type        = string
}

variable "vnet_address_space" {
  description = "Virtual network address space that contains the bastion host"
  type        = list
}

variable "vnet_subnet_address" {
  description = "Virtual network subnet address that contains the bastion host"
  type        = string
}

variable "bastion_name" {
  description = "Name of the bastion host"
  type        = string
}

variable "bastion_username" {
  description = "Bastion host username"
  type        = string
  default     = "devops"
}

variable "environment" {
  description = "Name of the environment for which the bastion is being deployed"
  type        = string
}