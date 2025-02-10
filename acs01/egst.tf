locals {
  function_deployed = false
}

resource "azurerm_resource_group" "egst" {
  name     = "rg-egst-${var.affix}-01"
  location = var.location
}

resource "azurerm_eventgrid_system_topic" "egst" {
  name                   = "egst-${var.affix}-01"
  resource_group_name    = azurerm_resource_group.egst.name
  location               = var.location
  topic_type             = "Microsoft.Storage.StorageAccounts"
  source_arm_resource_id = azurerm_storage_account.egst.id
}

resource "azurerm_eventgrid_system_topic_event_subscription" "egst" {
  count = local.function_deployed ? 1 : 0
  name = "func-trigger"
  resource_group_name = azurerm_resource_group.egst.name
  system_topic = azurerm_eventgrid_system_topic.egst.name
  azure_function_endpoint {
    function_id = "${azapi_resource.func.id}/functions/Send_Email"
  }
}

resource "azurerm_storage_account" "egst" {
  name                            = "stegst123321${var.env}01"
  resource_group_name             = azurerm_resource_group.egst.name
  location                        = var.location
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  account_kind                    = "StorageV2"
  access_tier                     = "Hot"
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  network_rules {
    default_action = "Allow"
    ip_rules       = []
    bypass = [
      "AzureServices",
      "Logging",
      "Metrics"
    ]
  }
}
