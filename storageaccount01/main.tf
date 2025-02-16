terraform {
  required_version = ">= 1.10.0"

  backend "azurerm" {
    storage_account_name = "stabcdefault02"
    container_name       = "tfstate"
    key                  = "st01.terraform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.18.0"
    }
  }
}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true

  features {}
}

locals {
  pdnsz = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.queue.core.windows.net",
  ]
}

resource "azurerm_private_dns_zone" "dns" {
  count               = length(local.pdnsz)
  name                = local.pdnsz[count.index]
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns" {
  count                 = length(local.pdnsz)
  name                  = "${azurerm_virtual_network.vnet.name}-vnetlink"
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.dns[count.index].name
}
