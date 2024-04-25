terraform {
  required_version = ">= 1.8.0"

  #backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.12.0"
    }
  }
}

provider "azurerm" {
  tenant_id           = "x-43c6-a39a-3fc5167644de"
  subscription_id     = "x-483e-95aa-fe7e71802e2e"
  storage_use_azuread = true

  features {}
}

provider "azapi" {
  tenant_id       = "x-43c6-a39a-3fc5167644de"
  subscription_id = "x-483e-95aa-fe7e71802e2e"
}


