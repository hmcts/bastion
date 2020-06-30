locals {
  env_display_names = {
    sbox-intsvc    = "Sandbox"
    prod-intsvc    = "Production"
    nonprod-intsvc = "Non-Production"
    test           = "Test"
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
}