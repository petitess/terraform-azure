locals {
  func_config = {
    app_settings = [{
      name  = "AzureWebJobsStorage"
      value = azurerm_storage_account.func.primary_connection_string
    },
    {
      name  = "CommunicationSrvUrl"
      value = "https://${azurerm_communication_service.acs.name}.europe.communication.azure.com"
    },
    {
      name  = "DoNotReplyEmail"
      value = "DoNotReply@${azurerm_email_communication_service_domain.acs.mail_from_sender_domain}"
    },
    {
      name  = "RecipientEmail"
      value = "email@abc.com"
    }]
  }
  st_name    = "stfunc123321${var.env}01"
  containers = ["func01"]
}

resource "azurerm_resource_group" "func" {
  name     = "rg-func-${var.affix}-01"
  location = var.location
}

resource "azurerm_service_plan" "func" {
  location            = var.location
  name                = "asp-func-${var.affix}-01"
  resource_group_name = azurerm_resource_group.func.name
  sku_name            = "FC1"
  os_type             = "Linux"
}

resource "azapi_resource" "func" {
  type      = "Microsoft.Web/sites@2024-04-01"
  name      = "func-linux-${var.affix}-01"
  parent_id = azurerm_resource_group.func.id
  location  = var.location
  identity {
    type = "SystemAssigned"
  }
  body = {
    kind = "functionapp,linux"
    properties = {
      serverFarmId        = azurerm_service_plan.func.id
      httpsOnly           = true
      publicNetworkAccess = "Enabled"
      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobcontainer"
            value = "${azurerm_storage_account.func.primary_blob_endpoint}${azurerm_storage_container.container["func01"].name}"
            authentication = {
              type = "systemassignedidentity"
            }
          }
        }
        runtime = {
          name    = "dotnet-isolated"
          version = "8.0"
        }
        scaleAndConcurrency = {
          instanceMemoryMB     = 2048
          maximumInstanceCount = 40
          triggers             = {}
        }
      }

      siteConfig = {
        minTlsVersion = "1.2"
        http20Enabled = true
        cors = {
          allowedOrigins = [
            "https://portal.azure.com"
          ]
          supportCredentials = false
        }
        appSettings = lookup(local.func_config, "app_settings", [])
      }
    }
  }
}

resource "azurerm_role_assignment" "func" {
  scope                = azurerm_resource_group.func.id
  principal_id         = azapi_resource.func.identity[0].principal_id
  role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "acs" {
  scope                = azurerm_resource_group.acs.id
  principal_id         = azapi_resource.func.identity[0].principal_id
  role_definition_name = "Contributor"
}

resource "azurerm_storage_account" "func" {
  name                            = local.st_name
  resource_group_name             = azurerm_resource_group.func.name
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
  blob_properties {
    change_feed_enabled           = true
    change_feed_retention_in_days = 21
    versioning_enabled            = false
    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "container" {
  for_each = {
    for container in local.containers : container => container
  }
  name               = each.value
  storage_account_id = azurerm_storage_account.func.id
}