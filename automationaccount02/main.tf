terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "~= 3.80"  for production
      version = ">= 3.86.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "sub" {}

data "local_file" "run" {
  for_each = fileset(".", "runbooks/*.ps1")
  filename = each.value
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-aa-${var.prefix}-01"
  location = var.location
  tags     = var.tags
}

