terraform {
  required_version = "~> 1.8.0"

  backend "azurerm" {
    container_name   = "tfstate-system"
    key              = "data.terraform.tfstate"
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.102.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.13.0"
    }
  }
}

provider "azurerm" {
  client_id           = var.client_id
  tenant_id           = var.tenant_id
  subscription_id     = var.sub_id
  use_oidc            = true
  storage_use_azuread = true

  features {}
}

provider "azapi" {
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  subscription_id = var.sub_id
  use_oidc        = true
}
