terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "~= 3.30"  for production
      version = ">= 3.30.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "sub" {}

resource "azurerm_resource_group" "infra" {
  name     = "rg-${var.prefix}-01"
  location = var.location
  tags     = var.tags
}

module "vms" {
  for_each = var.vms
  depends_on = [
    azurerm_virtual_network.vnet
  ]
  source          = "./vm"
  admin_password  = "12345678.abc"
  admin_username  = "azadmin"
  availname       = each.value.availname
  datadisk        = each.value.datadisks
  env             = var.env
  externalLBid    = azurerm_lb_backend_address_pool.lb.id
  internalLBid    = azurerm_lb_backend_address_pool.lbi.id
  location        = var.location
  name            = each.value.name
  offer           = each.value.image_reference.offer
  os_disk_size_gb = each.value.os_disk_size_gb
  nic             = each.value.network_interface
  prefix          = var.prefix
  planname        = each.value.plan.name
  planproduct     = each.value.plan.product
  planpublisher   = each.value.plan.publisher
  publisher       = each.value.image_reference.publisher
  rginfraname     = azurerm_resource_group.infra.name
  rgname          = each.value.rgname
  size            = each.value.size
  sku             = each.value.image_reference.sku
  tags            = merge(var.tags, each.value.tags)
  versionx        = each.value.image_reference.versionx
  vnetname        = azurerm_virtual_network.vnet.name
}
