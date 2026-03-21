resource "azurerm_key_vault" "keyvault" {

  name                          = local.key_vault_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = local.location
  sku_name                      = "standard"
  tenant_id                     = data.azurerm_subscription.sub.tenant_id
  enabled_for_disk_encryption   = false
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = true
  rbac_authorization_enabled    = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
    ip_rules       = [local.my_ip]
  }
  tags = local.tags
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                          = "pep-${local.key_vault_name}"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.rg.name
  tags                          = local.tags
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${local.key_vault_name}"

  private_service_connection {
    name                           = "plsc"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names              = ["Vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "vaultcore"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(var.pdnsz, "privatelink.vaultcore.azure.net")].id
    ]
  }
}

resource "azurerm_key_vault_secret" "pypi-pw" {
  name         = "pypi-pw"
  value        = "p@ssword"
  key_vault_id = azurerm_key_vault.keyvault.id
}

resource "azurerm_key_vault_secret" "pypi-user" {
  name         = "pypi-user"
  value        = "user01"
  key_vault_id = azurerm_key_vault.keyvault.id
}
