resource "azurerm_monitor_data_collection_rule" "win" {
  name                = "DataRuleWin-${var.env}01"
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.infra.name
  kind                = "Windows"
  data_sources {
    windows_event_log {
      name    = "eventLogsDataSource"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Application!*[System[(Level=1 or Level=2 or Level=3)]]",
        "System!*[System[(Level=1 or Level=2 or Level=3)]]"
      ]
    }
  }
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.log.id
      name                  = azurerm_log_analytics_workspace.log.name
    }
  }
  data_flow {
    streams      = ["Microsoft-Event"]
    destinations = ["${azurerm_log_analytics_workspace.log.name}"]
  }
}

