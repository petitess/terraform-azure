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

module "vmsnetcore" {
  for_each = var.vmsnetcore
  source = "./vmavail"
  admin_password = "12345678.abc"
  admin_username = "azadmin"
  app = var.app
  availname = each.value.availname
  deploydisk01 = each.value.datadisk01.deploydisk01
  publicip = each.value.network_interface.publicip
  disk_size_gb = each.value.datadisk01.disk_size_gb
  env = var.env
  location = var.location
  name = each.value.name
  offer = each.value.image_reference.offer
  os_disk_size_gb = each.value.os_disk_size_gb
  prefix = var.prefix
  primary = each.value.network_interface.primary
  private_ip_address = each.value.network_interface.private_ip_address
  private_ip_address_allocation = each.value.network_interface.private_ip_address_allocation
  publisher = each.value.image_reference.publisher
  rgname = each.value.rgname
  size = each.value.size
  sku = each.value.image_reference.sku
  subnet_id = azurerm_subnet.core.id
  tags = merge(var.tags, each.value.tags)
  versionx = each.value.image_reference.versionx
}
