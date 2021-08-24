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

  backend_config_json = jsonencode({ "script" : filebase64("${path.module}/mountfs.sh") })
}