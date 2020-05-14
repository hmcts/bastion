#--------------------------------------------------------------
# Terraform Storage Account
#--------------------------------------------------------------

resource "azurerm_storage_account" "bastion_storage_account" {
  name                            = "${var.bastion_name}infra${var.environment}sa"
  resource_group_name             = azurerm_resource_group.bastion_infra_resource_group.name
  location                        = azurerm_resource_group.bastion_infra_resource_group.location
  account_tier                    = element(split("_", var.storage_account_type), 0)
  account_replication_type        = element(split("_", var.storage_account_type), 1)


  tags                            = var.tags

  lifecycle {
    prevent_destroy               = true
  }
}

resource "azurerm_storage_container" "bastion_storage_container" {
  name                            = "terraform-state"
  storage_account_name            = azurerm_storage_account.bastion_storage_account.name
  container_access_type           = "private"

  lifecycle {
    prevent_destroy               = true
  }
}
