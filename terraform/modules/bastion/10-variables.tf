variable "location" {
  description = "Azure resource location"
  default     = "uksouth"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name that contains the bastion host"
  type        = string
}

variable "image_version" {
  description = "Version number of the shared image to use when building this VM"
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

variable "disk_size" {
  description = "Size of the data disk"
  default     = "1000"
}

variable "storage_type" {
  description = "Storage type of the data disk"
  type        = string
  default     = "StandardSSD_LRS"
}

variable "create_disks" {
  default = false
}

variable "soc_vault_name" {
  default = "soc-prod"
}

# Dynatrace OneAgent
variable "cnp_vault_rg" {
  type = string
}

variable "cnp_vault_sub" {
  type = string
}
variable "dynatrace_tenant_id" {
  type = string
}

variable "dynatrace_server" {
  type    = string
  default = null
}

# Splunk UF
variable "soc_vault_rg" {
  default = "soc-core-infra-prod-rg"
}

variable "splunk_username_secret" {
  default = "splunk-gui-admin-username"
}

variable "splunk_password_secret" {
  default = "splunk-gui-admin-password"
}

variable "splunk_pass4symmkey_secret" {
  default = "pass4SymmKey-forwarders-plaintext"
}

# Tenable Nessus
variable "nessus_server" {
  type = string
}

variable "nessus_key_secret" {
  type = string
}

variable "autoShutdown" {
  description = "Auto shutdown setting for the Linux virtual machine"
  type        = bool
}