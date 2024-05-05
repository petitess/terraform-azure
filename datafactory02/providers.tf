terraform {
  required_version = ">= 1.8.0"

  #backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.102.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.12.0"
    }

    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.42.0"
    }
  }
}

provider "azurerm" {
  tenant_id           = var.tenantid
  subscription_id     = var.subid
  storage_use_azuread = true

  features {}
}

provider "azapi" {
  tenant_id       = var.tenantid
  subscription_id = var.subid
}

provider "databricks" {
  host                        = azurerm_databricks_workspace.dbw.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.dbw.id
  azure_tenant_id             = data.azurerm_subscription.sub.tenant_id
}
