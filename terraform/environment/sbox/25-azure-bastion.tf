module "azure-bastion" {
  source = "../../modules/bastion/"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = "bastion-sbox-rg"
  virtual_network_name = "bastion-sbox-vnet"

  # Azure bastion server requireemnts
  azure_bastion_service_name          = "mybastion-service"
  azure_bastion_subnet_address_prefix = ["10.1.5.0/26"]
  bastion_host_sku                    = "Standard"
  scale_units                         = 10

  # Adding TAG's to your Azure resources (Required)
  tags = {}
}



module "bastion-sbox" {
  source              = "../../modules/bastion/"
  location            = module.bootstrap.resource_group.location
  environment         = local.environment
  image_version       = local.image_version
  resource_group_name = module.bootstrap.resource_group.name
  subnet_id           = module.bootstrap.subnet.id
  keyvault_id         = module.bootstrap.keyvault.id
  bastion_name        = "bastion-sbox"
  disk_size           = "100"
  storage_type        = "StandardSSD_LRS"
  create_disks        = true
  # Dynatrace OneAgent
  cnp_vault_rg        = "cnp-core-infra"
  cnp_vault_sub       = "1c4f0704-a29e-403d-b719-b90c34ef14c9"
  dynatrace_tenant_id = "yrk32651"
  dynatrace_server    = "https://10.10.70.6:9999/e/yrk32651/api"
  # Tenable Nessus
  nessus_server     = "nessus-scanners-sbox000006.platform.hmcts.net"
  nessus_key_secret = "nessus-agent-key-sbox"
}


resource "azurerm_public_ip" "bastion_ip" {
  count               = var.az_bastion_subnet == null ? 0 : 1
  name                = "azure-bastion-ip"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.bastionrg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = module.ctags.common_tags
}

resource "azurerm_bastion_host" "bastion" {
  count               = var.az_bastion_subnet == null ? 0 : 1
  name                = "jumpbox-bastion-${var.env}"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.bastionrg.name
  sku                 = "Standard"
  tunneling_enabled   = true
  tags                = module.ctags.common_tags

  ip_configuration {
    name                 = "ip-config"
    subnet_id            = azurerm_subnet.bastion_subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion_ip[0].id
  }
}
