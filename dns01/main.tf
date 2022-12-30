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

resource "azurerm_resource_group" "rgdns" {
  name = "rg-dns${var.env}-01"
  location = var.location
  tags = var.tags
}

module "dns" {
  for_each = var.dns
  source = "./dns"
  tags = var.tags
  rgname = azurerm_resource_group.rgdns.name
  arecord = each.value.arecords
  aaaa = each.value.aaaa
  caa = each.value.caa
  cname = each.value.cname
  mx = each.value.mx
  ns = each.value.ns
  ptr = each.value.ptr
  srv = each.value.srv
  txt = each.value.txt
  zonename = each.value.zonename
}