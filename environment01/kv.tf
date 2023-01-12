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
    tenant_id = data.azurerm_subscription.sub.tenant_id
    network_acls {
      bypass = "AzureServices"
      default_action = "Allow"
    }
}



