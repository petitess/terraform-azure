resource "azurerm_recovery_services_vault" "rsv" {
  name                = "rsv-${var.prefix}-01"
  tags                = var.tags
  location            = var.location
  resource_group_name = azurerm_resource_group.infra.name
  sku                 = "Standard"
  soft_delete_enabled = false
}

resource "azurerm_backup_policy_vm" "vm" {
  name                = "Default"
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  resource_group_name = azurerm_resource_group.infra.name
  timezone            = "W. Europe Standard Time"
  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  retention_daily {
    count = 30
  }
}

resource "azurerm_backup_policy_file_share" "file" {
  name                = "FilesharePolicy"
  resource_group_name = azurerm_resource_group.infra.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv.name
  timezone            = "W. Europe Standard Time"
  backup {
    frequency = "Daily"
    time      = "23:00"
  }
  retention_daily {
    count = 30
  }
}