terraform {
  required_version = ">= 1.8.0"

  backend "azurerm" {
    container_name   = "tfstate-databricks"
    key              = "databricks.terraform.tfstate"
    use_azuread_auth = true
  }

  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.47.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.106.0"

    }
  }
}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true

  features {}
}

provider "databricks" {
  host = data.azurerm_databricks_workspace.dbw.workspace_url
  azure_workspace_resource_id = data.azurerm_databricks_workspace.dbw.id
}
