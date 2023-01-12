resource "azurerm_recovery_services_vault" "rsv" {
    name = "rsv-${var.prefix}-01"
    tags = var.tags
    location = var.location
    resource_group_name = azurerm_resource_group.rginfra.name
    sku = "Standard"
    soft_delete_enabled = false

}

resource "azurerm_backup_policy_vm" "vm" {
    name = "Default"
    recovery_vault_name = azurerm_recovery_services_vault.rsv.name
    resource_group_name = azurerm_resource_group.rginfra.name
    backup {
        frequency = "Daily"
        time      = "23:00"
    }
    retention_daily {
      count = 30
    }
}

