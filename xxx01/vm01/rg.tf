resource "azurerm_resource_group" "rginfra" {
  name = "rgx-${var.prefix}-01"
  location = var.location
  tags = var.tags
}