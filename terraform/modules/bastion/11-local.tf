locals {
  env_display_names = {
    sbox    = "Sandbox"
    prod    = "Production"
    nonprod = "Non-Production"
    test    = "Test"
  }

  log_analytics_workspace = var.log_analytics_workspace_names[var.environment]
  dcr_subscription        = var.log_analytics_sub_id[local.log_analytics_workspace]

  common_tags = {
    "managedBy"          = "DevOps"
    "solutionOwner"      = "RDO"
    "activityName"       = "Mgmt Bastion IaaS"
    "dataClassification" = "Internal"
    "automation"         = ""
    "costCentre"         = ""
    "environment"        = local.env_display_names[var.environment]
  }

  dynatrace_env = var.dynatrace_tenant_id == "yrk32651" ? "nonprod" : var.dynatrace_tenant_id == "ebe20728" ? "prod" : null
}
