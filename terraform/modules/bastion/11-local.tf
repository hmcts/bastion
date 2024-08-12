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
    "autoShutdown"       = local.include_in_autoshutdown
    "startupMode"        = "always",
  }

  dynatrace_env = var.dynatrace_tenant_id == "yrk32651" ? "nonprod" : var.dynatrace_tenant_id == "ebe20728" ? "prod" : null

  include_in_autoshutdown = local.env_display_names[var.environment] == "Production" ? "false" : "true"

  merged_tags = merge(module.ctags.common_tags, local.common_tags)
}