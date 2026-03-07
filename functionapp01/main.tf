terraform {
  required_version = "1.14.4"
  required_providers {
    azurerm = {
      version = "4.63.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "vnet" {
  name     = "rg-vnet-${local.prefix}-01"
  location = local.location
}

resource "azurerm_private_dns_zone" "dns" {
  count               = length(local.pdnsz)
  name                = local.pdnsz[count.index]
  resource_group_name = azurerm_resource_group.vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns" {
  count                 = length(local.pdnsz)
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.dns[count.index].name
}

resource "azurerm_resource_group" "func_commmon" {
  name     = "rg-func-common-${local.prefix}-01"
  location = local.location
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-${local.prefix}-01"
  location            = local.location
  tags                = local.tags
  resource_group_name = azurerm_resource_group.func_commmon.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}

resource "azurerm_application_insights" "appi" {
  name                          = "appi-${local.prefix}-01"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.func_commmon.name
  workspace_id                  = azurerm_log_analytics_workspace.log.id
  application_type              = "web"
  local_authentication_disabled = true
}

resource "azurerm_service_plan" "func" {
  name                = "asp-elastic-premium-${local.prefix}-01"
  location            = azurerm_resource_group.func_commmon.location
  resource_group_name = azurerm_resource_group.func_commmon.name
  sku_name            = "EP1"
  os_type             = "Linux"
}
