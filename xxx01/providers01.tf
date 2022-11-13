terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.30.0"
    #version = "~= 3.30"  for production
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "main" {
  name = "rg-terraform-test01"
  location = "swedencentral"
}
