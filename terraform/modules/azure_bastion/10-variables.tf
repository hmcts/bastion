variable "location" {
  description = "Azure resource location"
  default     = "uksouth"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name that contains the azure bastion host"
  type        = string
}

variable "subnet_id" {
  description = "Virtual network subnet id that contains the azure bastion host"
  type        = string
}

variable "environment" {
  description = "Name of the environment for which the azure bastion is being deployed"
  type        = string
}

variable "azbastion_subnet_address" {
  description = "Virtual network subnet address that contains the azure bastion host"
  type        = string
}

variable "virtual_network_name" {
  description = "Virtual network name that contains the bastion host"
  type        = string
}
