terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = ">= 3.30.0"
    #version = "~= 3.30"  for production
    version = ">= 3.30.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}

resource "azurerm_resource_group" "main" {
  name = "rg-terraform-sc01"
  location = "swedencentral"
  tags = {
    "Environment" = "test"
  }
}

