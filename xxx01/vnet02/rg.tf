resource "azurerm_resource_group" "rginfra" {
  name = "rgx-${local.prefix}-01"
  location = var.location
  tags = local.tags
}
