terraform {
  required_version = ">= 1.8.0"

  #   backend "azurerm" {
  #     container_name   = "tfstate"
  #     key              = "infra-system.terraform.tfstate"
  #     use_azuread_auth = true
  #   }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53.0"
    }
  }

}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true
  features {}
}

provider "azuread" {
  tenant_id = data.azurerm_subscription.sub.tenant_id
}
