terraform {
  required_version = ">= 1.9.8"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.9.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.0.1"
    }
  }
}

provider "azurerm" {
  tenant_id           = "guid-123"
  subscription_id     = "guid-123"
  storage_use_azuread = true

  features {}
}

provider "azapi" {
  tenant_id       = "guid-123"
  subscription_id = "guid-123"
}

locals {
  location     = "swedencentral"
  prefix       = "dev"
  user_object_id = ""
  table_name = "githubtest"
  dataStructure = [
    {
      name = "TimeGenerated"
      type = "datetime"
    },
    {
      name = "RawData"
      type = "string"
    },
    {
      name = "Repo"
      type = "string"
    },
    {
      name = "Pipeline"
      type = "string"
    },
    {
      name = "Status"
      type = "string"
    },
    {
      name = "Info"
      type = "string"
    }
  ]
}

resource "azurerm_resource_group" "monitor" {
  name     = "rg-monitor-${local.prefix}-01"
  location = local.location
}

resource "azurerm_role_assignment" "monitor" {
  count                = local.user_object_id != "" ? 1 : 0
  scope                = azurerm_resource_group.monitor.id
  principal_id         = local.user_object_id
  role_definition_name = "Monitoring Metrics Publisher"
}

resource "azurerm_log_analytics_workspace" "monitor" {
  name                = "log-${local.prefix}-01"
  location            = local.location
  resource_group_name = azurerm_resource_group.monitor.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azapi_resource" "log_table" {
  type                      = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"
  name                      = "${local.table_name}_CL"
  parent_id                 = azurerm_log_analytics_workspace.monitor.id
  schema_validation_enabled = false
  body = {
    properties = {
      totalRetentionInDays = 30
      plan                 = "Analytics"
      schema = {
        name    = "${local.table_name}_CL"
        columns = local.dataStructure
      }
      retentionInDays = 30
    }
  }
}

resource "azurerm_monitor_data_collection_endpoint" "monitor" {
  name                          = "dce-${local.prefix}-01"
  resource_group_name           = azurerm_resource_group.monitor.name
  location                      = local.location
  public_network_access_enabled = true
}

resource "azurerm_monitor_data_collection_rule" "monitor" {
  name                        = "dcr-${local.prefix}-01"
  resource_group_name         = azurerm_resource_group.monitor.name
  location                    = local.location
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.monitor.id
  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.monitor.id
      name                  = azurerm_log_analytics_workspace.monitor.name
    }
  }
  data_flow {
    streams       = ["Custom-${local.table_name}_CL"]
    destinations  = [azurerm_log_analytics_workspace.monitor.name]
    transform_kql = "source"
    output_stream = "Custom-${local.table_name}_CL"
  }
  dynamic "stream_declaration" {
    for_each = local.dataStructure
    content {
      stream_name = "Custom-${local.table_name}"
      column {
        name = stream_declaration.value.name
        type = stream_declaration.value.type
      }
    }
  }
}
