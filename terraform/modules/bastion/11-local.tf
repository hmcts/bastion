locals {
  env_display_names = {
    sbox    = "Sandbox"
    prod    = "Production"
    nonprod = "Non-Production"
    test    = "Test"
  }

  common_tags = {
    "managedBy"          = "DevOps"
    "solutionOwner"      = "RDO"
    "activityName"       = "Mgmt Bastion IaaS"
    "dataClassification" = "Internal"
    "automation"         = ""
    "costCentre"         = ""
    "environment"        = local.env_display_names[var.environment]
  }

  backend_config_json = jsonencode({ "script" : filebase64("${path.module}/configure-bastion.sh") })
  splunk_username     = try(data.azurerm_key_vault_secret.splunk_username[0].value, false)
  splunk_password     = try(data.azurerm_key_vault_secret.splunk_password[0].value, false)
  splunk_pass4symmkey = try(data.azurerm_key_vault_secret.splunk_pass4symmkey[0].value, false)
}
