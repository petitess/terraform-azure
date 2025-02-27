terraform {
  required_version = ">= 1.10.0"

  backend "azurerm" {
    storage_account_name = "stabcdefault01"
    container_name       = "tfstate"
    key                  = "infra.terraform.tfstate"
    use_azuread_auth     = true
  }

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

resource "azurerm_resource_group" "traf" {
  name     = "rg-traf-${var.env}-01"
  location = var.location
}

resource "azurerm_traffic_manager_profile" "traf" {
  name                   = "traf-${var.env}-01"
  resource_group_name    = azurerm_resource_group.traf.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "123abc"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "traf_we" {
  name               = "app-we"
  profile_id         = azurerm_traffic_manager_profile.traf.id
  target_resource_id = module.app_avm["app_we"].resource_id
  weight             = 50
}

resource "azurerm_traffic_manager_azure_endpoint" "traf_ne" {
  name               = "app-ne"
  profile_id         = azurerm_traffic_manager_profile.traf.id
  target_resource_id = module.app_avm["app_ne"].resource_id
  weight             = 50
}
