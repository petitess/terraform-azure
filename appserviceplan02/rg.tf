resource "azurerm_resource_group" "rgapp" {
  name = "rg-app${var.env}-01"
  location = var.location
  tags = var.tags
}