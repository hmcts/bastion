variable "location" {
  description = "Azure resource location"
  default     = "uksouth"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name that contains the azure bastion host"
  type        = string
}

variable "environment" {
  description = "Name of the environment for which the azure bastion is being deployed"
  type        = string
}

variable "azbastion_subnet_address" {
  description = "Virtual network subnet address that contains the azure bastion host"

}

variable "virtual_network_name" {
  description = "Virtual network name that contains the bastion host"
  type        = string
}

variable "public_ip_name" {
  type        = string
  description = "Public IP of the Bastion"
}
variable "allocation_method" {
  type        = string
  description = "Specify Static or Dynamic"
}

variable "public_ip_sku" {
  type        = string
  description = "Enter the SKU for the Public IP of the Bastion"
}

variable "bastion_name" {
  type        = string
  description = "Name of the bastion host"
}

variable "bastion_sku" {
  type        = string
  description = "Specify SKU for the bastion host"
}

variable "tunneling_enabled" {
  type        = bool
  description = "Select True or False, tunneling is only supported when sku is Standard"
}

variable "ip_config_name" {
  type        = string
  description = "IP config name"
}