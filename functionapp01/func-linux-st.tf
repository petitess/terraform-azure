locals {
  st_linux = {
    public_network_access_enabled        = true
    network_rules_network_access_enabled = false
    shared_access_key_enabled            = true
    versioning_enabled                   = false
    containers                           = toset([])
    shares = toset([
      "func"
    ])
    private_endpoints = toset([
      "blob",
      "file"
    ])
  }
}

resource "azurerm_storage_account" "linux" {
  location                         = local.location
  name                             = "stlinux123${local.prefixShort}01"
  resource_group_name              = azurerm_resource_group.func_linux.name
  account_tier                     = "Standard"
  account_replication_type         = "LRS"
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  enable_https_traffic_only        = true
  cross_tenant_replication_enabled = true
  access_tier                      = "Hot"
  public_network_access_enabled    = lookup(local.st_linux, "public_network_access_enabled", false)
  shared_access_key_enabled        = lookup(local.st_linux, "shared_access_key_enabled", false)
  sftp_enabled                     = lookup(local.st_linux, "sftp_enabled", false)
  default_to_oauth_authentication  = lookup(local.st_linux, "default_to_oauth_authentication", true)
  network_rules {
    default_action = local.st_win.network_rules_network_access_enabled ? "Allow" : "Deny"
    ip_rules       = [local.my_ip]
    bypass = [
      "AzureServices",
      "Logging",
      "Metrics"
    ]
  }
  blob_properties {
    change_feed_enabled = false
    versioning_enabled  = lookup(local.st_linux, "versioning_enabled", true)
    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "linux" {
  for_each             = lookup(local.st_linux, "containers", {})
  name                 = each.value
  storage_account_name = azurerm_storage_account.linux.name
}

resource "azurerm_storage_share" "linux" {
  for_each             = lookup(local.st_linux, "shares", {})
  name                 = each.value
  quota                = 1
  storage_account_name = azurerm_storage_account.linux.name
}

resource "azurerm_private_endpoint" "linux" {
  for_each                      = lookup(local.st_linux, "private_endpoints", {})
  location                      = local.location
  name                          = "pep-${azurerm_storage_account.linux.name}-${each.value}"
  resource_group_name           = azurerm_storage_account.linux.resource_group_name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_storage_account.linux.name}-${each.value}"

  private_service_connection {
    is_manual_connection           = false
    name                           = "pse-${azurerm_storage_account.linux.name}-${each.value}"
    private_connection_resource_id = azurerm_storage_account.linux.id
    subresource_names              = [each.value]
  }

  private_dns_zone_group {
    name                 = each.value
    private_dns_zone_ids = [azurerm_private_dns_zone.dns[index(var.pdnsz, "privatelink.${each.value}.core.windows.net")].id]
  }
}
