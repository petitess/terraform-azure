resource "azurerm_key_vault" "kv" {
    name = "kv-${var.prefix}-01"
    location = var.location
    resource_group_name = azurerm_resource_group.rginfra.name
    tags = var.tags
    sku_name = "standard"
    enable_rbac_authorization = true
    enabled_for_deployment = false
    enabled_for_disk_encryption = true
    enabled_for_template_deployment = true
    tenant_id = data.azurerm_subscription.current.tenant_id
    network_acls {
      bypass = "AzureServices"
      default_action = "Allow"
    }
}

resource "random_password" "pass" {
  for_each = merge(var.vmsnetcore, var.vmsnetapp, var.vmsnetmgmt)
  length = 20
  special = true
  override_special = "!#$"
  min_lower = 1
  min_numeric = 1
  min_special = 1
  min_upper = 11
}

resource "azurerm_key_vault_secret" "secret01" {
    for_each = merge(var.vmsnetcore, var.vmsnetapp, var.vmsnetmgmt)
    name = each.value.name
    key_vault_id = azurerm_key_vault.kv.id
    tags = var.tags
    value = random_password.pass[each.key].result
}