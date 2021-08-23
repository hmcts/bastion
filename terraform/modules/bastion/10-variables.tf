variable "location" {
  description = "Azure resource location"
  default     = "uksouth"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name that contains the bastion host"
  type        = string
}

variable "image_id" {
  description = "Image ID to use when building this VM"
  type        = string
}

variable "subnet_id" {
  description = "Virtual network subnet id that contains the bastion host"
  type        = string
}

variable "keyvault_id" {
  description = "Keyvault id that contains the bastion host secrets"
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

variable "public_key" {
  description = "Name of the SSH public key.  This file should be placed with the parent module Terraform files"
  type        = string
}

variable "disk_name" {
  description = "Name of the data disk"
  type        = string
  default     = ""
}

variable "disk_size" {
  description = "Size of the data disk"
  type        = string
  default     = "1000"
}

variable "storage_type" {
  description = "Storage type of the data disk"
  type        = string
  default     = ""
}