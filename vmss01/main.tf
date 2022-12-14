terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
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
  features {}
}

data "azurerm_subscription" "sub" {}

module "vms" {
  for_each = var.vmss
  depends_on = [
    azurerm_virtual_network.vnet
  ]
  source = "./vmss"
  admin_password = "12345678.abc"
  admin_username = "azadmin"
  app = var.app
  AzureMonitorWindowsAgent = each.value.AzureMonitorWindowsAgent
  publicip = each.value.network_interface.publicip
  env = var.env
  instances = each.value.instances
  location = var.location
  name = each.value.name
  offer = each.value.image_reference.offer
  os_disk_size_gb = each.value.os_disk_size_gb
  prefix = var.prefix
  primary = each.value.network_interface.primary
  private_ip_address = each.value.network_interface.private_ip_address
  private_ip_address_allocation = each.value.network_interface.private_ip_address_allocation
  publisher = each.value.image_reference.publisher
  size = each.value.size
  sku = each.value.image_reference.sku
  subnet_id = "${data.azurerm_subscription.sub.id}/resourceGroups/${azurerm_resource_group.rginfra.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.vnet.name}/subnets/${each.value.network_interface.subnet_name}"
  tags = merge(var.tags, each.value.tags)
  versionx = each.value.image_reference.versionx
}