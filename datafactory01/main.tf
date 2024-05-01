data "azurerm_subscription" "sub" {}

resource "azurerm_resource_group" "rg" {
  name = "rg-${var.prefix}-01"
  location = var.location
  tags = var.tags
}

resource "azurerm_resource_group" "dns" {
  name = "rg-dns-${var.env}-01"
  location = var.location
  tags = var.tags
}

resource "azurerm_resource_group" "adf" {
  name = "rg-adf-${var.env}-01"
  location = var.location
  tags = var.tags
}

resource "azurerm_private_dns_zone" "example" {
  count               = length(var.pdnsz)
  name                = var.pdnsz[count.index]
  resource_group_name = azurerm_resource_group.dns.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  count                 = length(var.pdnsz)
  name                  = "link-${count.index}"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = var.pdnsz[count.index]
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

