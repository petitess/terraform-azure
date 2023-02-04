resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-${var.prefix}01"
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.infra.name
  sku                 = "PerGB2018"
  retention_in_days   = 90
}
