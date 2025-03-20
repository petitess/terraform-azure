terraform {
  required_version = ">= 1.10.0"

  backend "azurerm" {
    container_name   = "tfstate-databricks"
    key              = "infra-system.terraform.tfstate"
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.23.0"
    }
  }
}

provider "azurerm" {
  subscription_id     = local.sub_id
  storage_use_azuread = true

  features {}
}
