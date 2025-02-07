locals {
  streams           = ["Microsoft-ContainerLog", "Microsoft-ContainerLogV2", "Microsoft-KubeEvents", "Microsoft-KubePodInventory", "Microsoft-KubeNodeInventory", "Microsoft-KubePVInventory", "Microsoft-KubeServices", "Microsoft-KubeMonAgentEvents", "Microsoft-InsightsMetrics", "Microsoft-ContainerInventory", "Microsoft-ContainerNodeInventory", "Microsoft-Perf"]
  syslog_facilities = ["auth", "authpriv", "cron", "daemon", "mark", "kern", "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7", "lpr", "mail", "news", "syslog", "user", "uucp"]
  syslog_levels     = ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
}

resource "azurerm_resource_group" "monitor" {
  name     = "rg-monitor-${var.env}-01"
  location = local.location
  tags     = local.tags
}
#https://learn.microsoft.com/en-us/azure/azure-monitor/containers/kubernetes-monitoring-enable?tabs=terraform#enable-prometheus-and-grafana
resource "azurerm_monitor_data_collection_endpoint" "aks" {
  name                          = "dce-${azurerm_kubernetes_cluster.aks.name}"
  resource_group_name           = azurerm_resource_group.monitor.name
  location                      = local.location
  public_network_access_enabled = true
}

resource "azurerm_monitor_data_collection_rule" "aks" {
  name                = "dcr-${azurerm_kubernetes_cluster.aks.name}"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = local.location
  description         = "DCR for Azure Monitor Container Insights"
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.aks.id
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.aks.id
      name                  = "log01"
    }
  }

  data_flow {
    streams      = local.streams
    destinations = ["log01"]
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["log01"]
  }

  data_sources {
    syslog {
      streams        = ["Microsoft-Syslog"]
      facility_names = local.syslog_facilities
      log_levels     = local.syslog_levels
      name           = "sysLogsDataSource"
    }

    extension {
      streams        = local.streams
      extension_name = "ContainerInsights"
      extension_json = jsonencode({
        "dataCollectionSettings" : {
          "interval" : "1m",
          "namespaceFilteringMode" : "Off",
          "namespaces" : ["kube-system", "gatekeeper-system", "azure-arc"]
          "enableContainerLogV2" : true
        }
      })
      name = "ContainerInsightsExtension"
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "dcra" {
  name                    = "ContainerInsightsExtension"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.aks.id
  description             = "Association of container insights data collection rule. Deleting this association will break the data collection for this AKS Cluster."
}

resource "azurerm_monitor_workspace" "monitor" {
  name                          = "monitor-${var.env}-01"
  location                      = azurerm_resource_group.monitor.location
  resource_group_name           = azurerm_resource_group.monitor.name
  public_network_access_enabled = true
  
}

resource "azurerm_monitor_data_collection_rule_association" "monitor" {
  name                    = "Prometheus"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_workspace.monitor.default_data_collection_rule_id
  description             = "Association of prometheus data collection rule. Deleting this association will break the data collection for this AKS Cluster."
}

resource "azurerm_private_endpoint" "monitor_pep" {
  name                          = "pep-${azurerm_monitor_workspace.monitor.name}"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.monitor.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_monitor_workspace.monitor.name}"
  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_monitor_workspace.monitor.id
    subresource_names              = ["prometheusMetrics"]
    is_manual_connection           = false
  }
  tags = local.tags
  private_dns_zone_group {
    name = "privatelink.swedencentral.prometheus.monitor.azure.com"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.swedencentral.prometheus.monitor.azure.com")].id
    ]
  }
}

resource "azurerm_dashboard_grafana" "monitor" {
  name                              = "grafana-${var.env}-01"
  tags                              = local.tags
  resource_group_name               = azurerm_resource_group.monitor.name
  location                          = local.location
  grafana_major_version             = 10
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true
  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.monitor.id
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "grafana_pep" {
  name                          = "pep-${azurerm_dashboard_grafana.monitor.name}"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.monitor.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_dashboard_grafana.monitor.name}"
  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_dashboard_grafana.monitor.id
    subresource_names              = ["grafana"]
    is_manual_connection           = false
  }
  tags = local.tags
  private_dns_zone_group {
    name = "privatelink.grafana.azure.com"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.grafana.azure.com")].id
    ]
  }
}

resource "azurerm_role_assignment" "grafana" {
  scope                = "/subscriptions/${var.subid}"
  principal_id         = azurerm_dashboard_grafana.monitor.identity[0].principal_id
  role_definition_name = "Reader"
}
