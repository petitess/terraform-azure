terraform {
  required_version = ">= 1.8.0"

  backend "azurerm" {
    container_name   = "tfstate-databricks"
    key              = "databricks.terraform.tfstate"
    use_azuread_auth = true
  }

  required_providers {
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
