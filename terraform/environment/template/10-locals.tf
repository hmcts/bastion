locals {
  environment             = "test"
  location                = "uksouth"
  image_id                = "/subscriptions/ea3a8c1e-af9d-4108-bc86-a7e2d267f49c/resourceGroups/rdo-bastion-packer/providers/Microsoft.Compute/images/rdo-bastion-image-85473"
  subnet                  = "10.48.0.64/27"
  hub_subscription_id     = "ea3a8c1e-af9d-4108-bc86-a7e2d267f49c"
  hub_vnet_name           = "hmcts-hub-test-int"
  hub_vnet_resource_group = "hmcts-hub-sbox-int"
  hub_lb_name             = "hmcts-hub-sbox-int-palo-lb"
  hub_lb_resource_group   = local.hub_vnet_resource_group
}