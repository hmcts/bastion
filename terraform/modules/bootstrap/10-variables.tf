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
  type        = list(any)
}

variable "subnet_name" {
  description = "Name of the virtual network subnet that contains the bastion host"
  type        = string
}

variable "subnet_address" {
  description = "Virtual network subnet address that contains the bastion host"
  type        = string
}

variable "keyvault_name" {
  description = "Name of the key vault that contains the bastion host secrets"
  type        = string
}

variable "environment" {
  description = "Name of the environment that contains the bastion host"
  type        = string
}

variable "hub_subscription_id" {
  description = "The subscription Id of the hub network"
  type        = string
}

variable "hub_lb_name" {
  description = "Name of the hub palo alto load balancer"
  type        = string
}

variable "hub_lb_resource_group" {
  description = "Name of the hub palo alto load balancer resource group"
  type        = string
}