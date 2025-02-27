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

  dynatrace_env       = var.dynatrace_tenant_id == "yrk32651" ? "nonprod" : var.dynatrace_tenant_id == "ebe20728" ? "prod" : null
  vm_bootstrap_source = "github.com/hmcts/terraform-module-vm-bootstrap?ref=DTSPO-17050-splunk-usf-version-update"
  is_sbox_env         = var.environment == "sbox" ? 1 : 0
}
