resource "azurerm_resource_group" "rginfra" {
  name = "rg-${var.prefix}-01"
  location = var.location
  tags = var.tags
}

resource "azurerm_resource_group" "lb" {
  name = "rg-lb-${var.env}-01"
  location = var.location
  tags = var.tags
}