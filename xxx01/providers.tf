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

provider "azurerm" {
  alias = "provider02-WE"
  features {
    virtual_machine {
      delete_os_disk_on_deletion = false
    }
  }
}

resource "azurerm_resource_group" "main" {
  name = "rg-terraform-sc01"
  location = "swedencentral"
}

resource "azurerm_resource_group" "second" {
  name = "rg-terraform-we01"
  location = "westeurope"
  provider = azurerm.provider02-WE
}
