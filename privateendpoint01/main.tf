terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "~= 3.30"  for production
      version = ">= 3.30"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "sub" {}

resource "azurerm_resource_group" "infra" {
  name = "rg-${var.prefix}-01"
  location = var.location
  tags = var.tags
}

module "st" {
  for_each = var.st
  source = "./st"
  fileshares = each.value.fileshares
  containers = each.value.containers
  kind = each.value.kind
  location = var.location
  name = each.value.name
  peblob = each.value.private_endpoint.blob
  pefile = each.value.private_endpoint.file
  pequeue = each.value.private_endpoint.queue
  petable = each.value.private_endpoint.table
  pesubnet = each.value.private_endpoint.subnet
  public_access = each.value.public_access
  public_networks = each.value.public_networks
  queues = each.value.queues
  replication = each.value.replication
  rgname = azurerm_resource_group.infra.name
  tables = each.value.tables
  tags = var.tags
  tier = each.value.tier
  versioning_enabled = each.value.versioning_enabled
  vnetname = azurerm_virtual_network.vnet.name
  
}