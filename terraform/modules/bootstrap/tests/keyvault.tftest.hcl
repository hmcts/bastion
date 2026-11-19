mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
      subscription_id = "b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac"
      object_id       = "43e023d9-c617-471f-aeda-2ad0efb97aac"
    }
  }
}

mock_provider "azurerm" {
  alias = "hub"
}

variables {
  resource_group_name   = "bastion-test-rg"
  vnet_name             = "bastion-test-vnet"
  vnet_address_space    = ["10.0.0.0/24"]
  subnet_name           = "bastion"
  subnet_address        = "10.0.0.0/27"
  keyvault_name         = "bastion-test-kv"
  environment           = "sbox"
  hub_subscription_id   = "ea3a8c1e-af9d-4108-bc86-a7e2d267f49c"
  hub_lb_name           = "test-lb"
  hub_lb_resource_group = "test-rg"
  routes                = []
  additional_key_vault_access_policies = {
    "43e023d9-c617-471f-aeda-2ad0efb97aac" = ["Get", "List", "Set", "Delete"]
    "083265d1-2e54-40ef-83bc-34fd5a1f1bcf" = ["Get", "List", "Set", "Delete"]
  }
}

run "legacy_caller_keeps_both_identities" {
  command = plan

  assert {
    condition = (
      length(azurerm_key_vault.bastion.access_policy) == 2 &&
      jsonencode(one([for policy in azurerm_key_vault.bastion.access_policy : policy.secret_permissions if policy.object_id == "43e023d9-c617-471f-aeda-2ad0efb97aac"])) == jsonencode(["Get", "List", "Set", "Delete"]) &&
      toset([for policy in azurerm_key_vault.bastion.access_policy : policy.object_id]) ==
      toset(["43e023d9-c617-471f-aeda-2ad0efb97aac", "083265d1-2e54-40ef-83bc-34fd5a1f1bcf"])
    )
    error_message = "The legacy bootstrap must preserve its access and add the WIF identity exactly once."
  }
}

run "wif_caller_keeps_legacy_identity" {
  command = plan

  override_data {
    target = data.azurerm_client_config.current
    values = {
      tenant_id       = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
      subscription_id = "b3394340-6c9f-44ca-aa3e-9ff38bd1f9ac"
      object_id       = "083265d1-2e54-40ef-83bc-34fd5a1f1bcf"
    }
  }

  assert {
    condition = (
      length(azurerm_key_vault.bastion.access_policy) == 2 &&
      contains([for policy in azurerm_key_vault.bastion.access_policy : policy.object_id], "43e023d9-c617-471f-aeda-2ad0efb97aac")
    )
    error_message = "Switching the pipeline to WIF must not remove legacy access or duplicate the WIF policy."
  }
}

run "existing_production_reader_stays_read_only" {
  command = plan

  variables {
    environment = "prod"
    additional_key_vault_access_policies = {
      "b7a68ebf-8ace-4855-9ea6-1f08ef0af8f9" = ["Get", "List", "Set", "Delete"]
      "5d16e46d-017b-4ae0-859c-22a10cce59e9" = ["Get", "List", "Set", "Delete"]
      "0f11e5e9-83e3-442f-a015-a6bda75912cd" = ["Get", "List"]
    }
  }

  override_data {
    target = data.azurerm_client_config.current
    values = {
      tenant_id       = "531ff96d-0ae9-462a-8d2d-bec7c0b42082"
      subscription_id = "2b1afc19-5ca9-4796-a56f-574a58670244"
      object_id       = "5d16e46d-017b-4ae0-859c-22a10cce59e9"
    }
  }

  assert {
    condition = (
      length(azurerm_key_vault.bastion.access_policy) == 3 &&
      toset(one([for policy in azurerm_key_vault.bastion.access_policy : policy.secret_permissions if policy.object_id == "0f11e5e9-83e3-442f-a015-a6bda75912cd"])) == toset(["Get", "List"])
    )
    error_message = "Preserving an existing reader must not give it secret-write permissions."
  }
}

run "default_preserves_existing_module_behavior" {
  command = plan

  variables {
    additional_key_vault_access_policies = {}
  }

  assert {
    condition     = length(azurerm_key_vault.bastion.access_policy) == 1
    error_message = "Without additional policies, only the existing caller policy should be configured."
  }
}
