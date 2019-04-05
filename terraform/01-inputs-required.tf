variable "key_vault_uri" {
  default = "https://__bastion_name__-kvs.vault.azure.net/"
}

variable "location" {
  default = "__bastion_location__"
}

variable "virtual_machine_name" {
  default = "__bastion_name__-vm"
}

variable "bastion_name" {
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