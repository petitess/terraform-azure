data "azurerm_subscription" "sub" {}

resource "azurerm_resource_group" "spoke" {
  name     = "rg-${var.prefix}-01"
  location = var.location
  tags     = var.tags
}



