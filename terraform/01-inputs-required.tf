variable "resource_group" {
  default = "__bastion_rg__"
}

variable "location" {
  default = "__bastion_location__"
}

variable "virtual_machine_name" {
  default = "__bastion_name__-vm"
}

variable "bastion_name" {
  type    = "string"
  default = "__bastion_name__"
}
variable "virtual_machine_count" {
    default = 1
}

variable "address_space" {
  description = "The address space used by the new vnet"
  default     = "10.97.101.0/28"
}

variable "ssh_key" {}