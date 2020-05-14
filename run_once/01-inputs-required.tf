variable "bastion_name" {}
variable "location" {}
variable "storage_account_type" {
  default = "Standard_LRS"
}
variable "environment" {}
variable "admin_username" {}
variable "admin_password" {}
variable "ssh-public-key" {}
variable "ssh-private-key" {}