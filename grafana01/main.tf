terraform {
  required_version = ">= 1.11.0"

  # backend "azurerm" {
  #   storage_account_name = "stabcdefault01"
  #   container_name       = "tfstate"
  #   key                  = "infra.terraform.tfstate"
  #   use_azuread_auth     = true
  # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.24.0"
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
    "privatelink.${var.location}.prometheus.monitor.azure.com",
    "privatelink.grafana.azure.com"
  ]
  deploy_prometheus = false
}

resource "azurerm_resource_provider_registration" "monitor" {
  name = "Microsoft.Monitor"
}

resource "azurerm_resource_provider_registration" "dashboard" {
  name = "Microsoft.Dashboard"
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

resource "azurerm_resource_group" "grafana" {
  name     = "rg-grafana-${var.env}-01"
  location = var.location
}

resource "azurerm_monitor_workspace" "monitor" {
  count                         = local.deploy_prometheus ? 1 : 0
  name                          = "monitor-${var.env}-01"
  location                      = azurerm_resource_group.grafana.location
  resource_group_name           = azurerm_resource_group.grafana.name
  public_network_access_enabled = true
}

resource "azurerm_dashboard_grafana" "grafana" {
  name                              = "grafana-${var.env}-01"
  resource_group_name               = azurerm_resource_group.grafana.name
  location                          = var.location
  grafana_major_version             = 11
  zone_redundancy_enabled           = false
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true
  sku                               = "Standard"

  dynamic "azure_monitor_workspace_integrations" {
    for_each = {
      for p in azurerm_monitor_workspace.monitor : p.name => p
      if local.deploy_prometheus
    }
    content {
      resource_id = azurerm_monitor_workspace.monitor[0].id
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "grafana" {
  scope                = "/subscriptions/${var.subid}"
  principal_id         = azurerm_dashboard_grafana.grafana.identity[0].principal_id
  role_definition_name = "Reader"
}

resource "azurerm_private_endpoint" "grafana" {
  name                          = "pep-${azurerm_dashboard_grafana.grafana.name}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.grafana.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_dashboard_grafana.grafana.name}"

  private_service_connection {
    name                           = "conn-${azurerm_dashboard_grafana.grafana.name}"
    private_connection_resource_id = azurerm_dashboard_grafana.grafana.id
    subresource_names              = ["grafana"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name = "privatelink.grafana.azure.com"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.grafana.azure.com")].id
    ]
  }
}

resource "azurerm_private_endpoint" "monitor" {
  count                         = local.deploy_prometheus ? 1 : 0
  name                          = "pep-${azurerm_monitor_workspace.monitor[0].name}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.grafana.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_monitor_workspace.monitor[0].name}"

  private_service_connection {
    name                           = "conn-${azurerm_monitor_workspace.monitor[0].name}"
    private_connection_resource_id = azurerm_monitor_workspace.monitor[0].id
    subresource_names              = ["prometheusMetrics"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name = "privatelink.${var.location}.prometheus.monitor.azure.com"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.${var.location}.prometheus.monitor.azure.com")].id
    ]
  }
}


