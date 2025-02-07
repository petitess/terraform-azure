resource "azurerm_key_vault" "kv" {
  name                            = "kv-${var.env}-abcd-01"
  location                        = local.location
  resource_group_name             = azurerm_resource_group.aks.name
  tags                            = local.tags
  sku_name                        = "standard"
  enable_rbac_authorization       = true
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

resource "azurerm_key_vault_secret" "secret" {
  count        = 0
  name         = "secret"
  key_vault_id = azurerm_key_vault.kv.id
  value        = "hejhej.123"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_private_endpoint" "kv_pep" {
  name                          = "pep-${azurerm_key_vault.kv.name}"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.aks.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_key_vault.kv.name}"
  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["Vault"]
    is_manual_connection           = false
  }
  tags = local.tags
  private_dns_zone_group {
    name = "privatelink.vaultcore.azure.net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.vaultcore.azure.net")].id
    ]
  }
}
