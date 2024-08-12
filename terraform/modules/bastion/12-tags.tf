module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom    = "https://github.com/hmcts/bastion"
  environment  = var.environment
  product      = "mgmt"
  expiresAfter = "3000-01-01" # never expire bastions
}

locals {
  include_in_autoshutdown = var.environment == "prod" ? "false" : "true"

  auto_shutdown_common_tags = {
    "startupMode"  = "always",
    "autoShutdown" = local.include_in_autoshutdown
  }

  merged_tags = merge(module.ctags.common_tags, local.auto_shutdown_common_tags)
}