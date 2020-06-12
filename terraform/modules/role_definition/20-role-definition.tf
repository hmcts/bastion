resource "azurerm_role_definition" "bastion-admin" {
  name        = "Virtual Machine Admin Login - ${var.bastion_name}"
  # scope       = data.azurerm_subscription.primary.id
  scope       = "/"
  description = "This is a custom role managed via Terraform - github.com/hmcts/rdo-bastion"

  permissions {
    actions      = [
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/loadBalancers/read",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Compute/virtualMachines/*/read"
      ]
    data_actions = [
      "Microsoft.Compute/virtualMachines/login/action",
      "Microsoft.Compute/virtualMachines/loginAsAdmin/action"
    ]
  }

  assignable_scopes = var.role_def_assignable_scopes
}

resource "azurerm_role_definition" "bastion-user" {
  name        = "Virtual Machine User Login - ${var.bastion_name}"
  scope       = "/"
  description = "This is a custom role managed via Terraform - github.com/hmcts/rdo-bastion"

  permissions {
    actions     = [
      "Microsoft.Network/publicIPAddresses/read",
      "Microsoft.Network/virtualNetworks/read",
      "Microsoft.Network/loadBalancers/read",
      "Microsoft.Network/networkInterfaces/read",
      "Microsoft.Compute/virtualMachines/*/read"
    ]
    data_actions = [
      "Microsoft.Compute/virtualMachines/login/action"
    ]
  }

  assignable_scopes = var.role_def_assignable_scopes
}