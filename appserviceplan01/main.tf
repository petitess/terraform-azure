terraform {
  required_version = ">= 1.10.0"

  # backend "azurerm" {
  #   storage_account_name = "stabcdefault01"
  #   container_name       = "tfstate"
  #   key                  = "infra.terraform.tfstate"
  #   use_azuread_auth     = true
  # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.20.0"
    }
  }
}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true

  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_service_plan" "name" {
  name                = "asp-${var.env}-01"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  os_type             = "Windows"
  sku_name            = "P1v2"
}
