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
  vm_bootstrap_source = var.environment == "sbox" ? "github.com/hmcts/terraform-module-vm-bootstrap?ref=DTSPO-17050-splunk-usf-version-update" : "github.com/hmcts/terraform-module-vm-bootstrap?ref=master"

}
