terraform {
  required_version = ">= 1.10.0"

  backend "azurerm" {
    storage_account_name = "stabcdefault02"
    container_name       = "tfstate"
    key                  = "kv01.terraform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.19.0"
    }
  }
}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true

  features {}
}

data "azurerm_client_config" "current" {}

locals {
  pdnsz = [
    "privatelink.vaultcore.azure.net"
  ]
  kv_name = "kv-${var.affixShort}-01"
}

resource "azurerm_private_dns_zone" "dns" {
  count               = length(local.pdnsz)
  name                = local.pdnsz[count.index]
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns" {
  count                 = length(local.pdnsz)
  name                  = "${azurerm_virtual_network.vnet.name}-vnetlink"
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.dns[count.index].name
}

resource "azurerm_log_analytics_workspace" "monitor" {
  name                = "log-${local.prefix}-01"
  location            = local.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_resource_group" "kv" {
  name     = "rg-kv-${var.affix}-01"
  location = local.location
  tags     = local.tags
}

resource "azurerm_key_vault" "kv" {
  name                          = local.kv_name
  resource_group_name           = azurerm_resource_group.kv.name
  sku_name                      = "standard"
  location                      = var.location
  tags                          = local.tags
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = true
  enable_rbac_authorization     = true
}

resource "azurerm_key_vault_secret" "kv" {
  name         = "secret01"
  key_vault_id = azurerm_key_vault.kv.id
  value        = "fake_value"
  lifecycle {
    ignore_changes = [value]
  }
}

ephemeral "azurerm_key_vault_secret" "kv" {
  name         = "secret01"
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_secret.kv]
}

resource "azurerm_private_endpoint" "kv" {
  name                          = "pep-${local.kv_name}"
  location                      = local.location
  tags                          = local.tags
  resource_group_name           = azurerm_resource_group.kv.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${local.kv_name}"
  private_service_connection {
    name                           = "psc-${local.kv_name}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["Vault"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name = "privatelink-vaultcore-azure-net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.vaultcore.azure.net")].id
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "diag-${local.kv_name}"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.monitor.id
  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
