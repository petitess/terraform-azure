terraform {
  required_version = ">= 1.8.0"

  backend "azurerm" {
    storage_account_name = "stabc01"
    container_name       = "tfstate-spokes"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.3.0"
    }
  }
}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true
  features {}
}

provider "azurerm" {
  subscription_id     = local.hub_sub_id
  storage_use_azuread = true
  alias               = "hub"
  features {}
}
