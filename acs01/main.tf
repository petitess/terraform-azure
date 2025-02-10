terraform {
  required_version = ">= 1.10.0"

  backend "azurerm" {
    storage_account_name = "stabcdefault01"
    container_name       = "tfstate"
    key                  = "acs.terraform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.2.0"
    }
  }
}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true

  features {}
}

provider "azapi" {
  subscription_id = var.subid
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "acs" {
  name     = "rg-acs-${var.affix}-01"
  location = var.location
}

resource "azurerm_communication_service" "acs" {
  name                = "acs-${var.affix}-01"
  resource_group_name = azurerm_resource_group.acs.name
  data_location       = "Europe"
}

resource "azurerm_email_communication_service" "acs" {
  name                = "aecs-${var.affix}-01"
  resource_group_name = azurerm_resource_group.acs.name
  data_location       = "Europe"
}

resource "azurerm_email_communication_service_domain" "acs" {
  name              = "AzureManagedDomain"
  email_service_id  = azurerm_email_communication_service.acs.id
  domain_management = "AzureManaged"
}

resource "azurerm_communication_service_email_domain_association" "acs" {
  communication_service_id = azurerm_communication_service.acs.id
  email_service_domain_id  = azurerm_email_communication_service_domain.acs.id
}