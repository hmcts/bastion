
variable "bastion_vm_name" {
  default = "__bastion_rg__-vm"
}
variable "bastion_vm_count" {
    default = 1
}

variable "ssh_key" {}