module "ctags" {
  source = "git::https://github.com/hmcts/terraform-module-common-tags?ref=DTSPO-18904/make-startupmode-optional"

  builtFrom    = "https://github.com/hmcts/bastion"
  environment  = var.environment
  product      = "mgmt"
  expiresAfter = "3000-01-01" # never expire bastions
  autoShutdown = var.autoShutdown
}
