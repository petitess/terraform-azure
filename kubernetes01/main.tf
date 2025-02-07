terraform {
  required_version = ">= 1.10.0"

  backend "azurerm" {
    storage_account_name = "stabcdefault01"
    container_name       = "tfstate"
    key                  = "infra.terraform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16.0"
    }
  }
}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true

  features {}
}

provider "azuread" {

}

data "azurerm_client_config" "current" {}

locals {
  aks_user = ""
  pdnsz = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.swedencentral.prometheus.monitor.azure.com",
    "privatelink.grafana.azure.com",
    "privatelink.azurecr.io"
  ]
}

resource "azurerm_role_assignment" "user" {
  count                = local.aks_user != "" ? 1 : 0
  scope                = azurerm_resource_group.aks.id
  principal_id         = local.aks_user
  role_definition_name = "Azure Kubernetes Service RBAC Admin"
}

resource "azurerm_role_assignment" "user_grafana" {
  count                = local.aks_user != "" ? 1 : 0
  scope                = "/subscriptions/${var.subid}"
  principal_id         = local.aks_user
  role_definition_name = "Grafana Admin"
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

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "log-${var.env}-01"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
