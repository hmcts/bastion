module "ctags" {
  source = "github.com/hmcts/terraform-module-common-tags"

  builtFrom   = "https://github.com/hmcts/bastion"
  environment = var.environment
  product     = "mgmt"
}
