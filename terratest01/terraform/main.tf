locals {
  sub_id         = var.sub_id
  prefix         = var.prefix
  location       = "swedencentral"
  key_vault_name = "kv-sys-${local.prefix}-01"
  allowed_ips    = []
  tags = {
    ENV = var.env
  }
}

data "azurerm_subscription" "sub" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.prefix}-01"
  location = local.location
}

resource "azurerm_key_vault" "kv" {
  name                          = local.key_vault_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = local.location
  sku_name                      = "standard"
  tenant_id                     = data.azurerm_subscription.sub.tenant_id
  enabled_for_disk_encryption   = false
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = true
  enable_rbac_authorization     = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules       = local.allowed_ips
  }
}

output "kv_public_access" {
  value = azurerm_key_vault.kv.public_network_access_enabled
}


