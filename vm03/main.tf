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

module "vms" {
  for_each = var.vms
  depends_on = [
    azurerm_virtual_network.vnet
  ]
  source = "./vm"
  admin_password = "12345678.abc"
  admin_username = "azadmin"
  AzureMonitorWindowsAgent = each.value.AzureMonitorWindowsAgent
  data_collection_rule_id = azurerm_monitor_data_collection_rule.win.id
  datadisk = each.value.datadisks
  env = var.env
  location = var.location
  name = each.value.name
  offer = each.value.image_reference.offer
  os_disk_size_gb = each.value.os_disk_size_gb
  nic = each.value.network_interface
  prefix = var.prefix
  publisher = each.value.image_reference.publisher
  rginfraname = azurerm_resource_group.rginfra.name
  size = each.value.size
  sku = each.value.image_reference.sku
  tags = merge(var.tags, each.value.tags)
  versionx = each.value.image_reference.versionx
  vnetname = azurerm_virtual_network.vnet.name
}