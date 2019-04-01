#
variable "tenant_id" {}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}

variable "bastion_rg" {
  default = "__bastion_rg__"
}

variable "bastion_vm_name" {
  default = "__bastion_rg__-vm"
}
variable "bastion_vm_count" {
    default = 1
}
variable "bastion_location" {
  default = "uksouth"
}

variable "ssh_key" {
  default = ""
}

variable "private_key" {
  default = ""
}
