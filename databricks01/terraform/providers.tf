terraform {
  required_version = ">= 1.14.7"

  backend "azurerm" {
    container_name   = "tfstate-databricks"
    key              = "infra-system.terraform.tfstate"
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.65.0"
    }
  }
}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true

  features {}
}
