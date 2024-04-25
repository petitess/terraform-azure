locals {
  key_vault_name = "kv-sys-${var.prefix}-01"
}

resource "azurerm_key_vault" "keyvault" {

  name                          = local.key_vault_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  sku_name                      = "standard"
  tenant_id                     = data.azurerm_subscription.sub.tenant_id
  enabled_for_disk_encryption   = true
  soft_delete_retention_days    = 90
  purge_protection_enabled      = false
  public_network_access_enabled = true
  enable_rbac_authorization     = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [var.my_ip]
  }
  tags = var.tags
}

resource "azurerm_private_endpoint" "kv_pe" {
  name                          = "pep-${local.key_vault_name}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-pep-${local.key_vault_name}"
  private_service_connection {
    name                           = "${local.key_vault_name}-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names              = ["Vault"]
    is_manual_connection           = false
  }
  tags = var.tags
}
