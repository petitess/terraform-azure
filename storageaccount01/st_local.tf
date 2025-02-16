locals {
  st_01 = {
    name              = "staks123321${var.affixShort}01"
    containers        = []
    fileshares        = ["node01"]
    queues            = []
    tables            = []
    private_endpoints = { file = "10.1.3.11", blob = "10.1.3.12" }
    my_ip             = "1.150.104.23"
  }
}

resource "azurerm_resource_group" "st_local" {
  name     = "rg-st-${var.affix}-01"
  location = local.location
  tags     = local.tags
}

resource "azurerm_storage_account" "st_local" {
  name                            = local.st_01.name
  tags                            = local.tags
  resource_group_name             = azurerm_resource_group.st_local.name
  location                        = local.location
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  account_kind                    = "StorageV2"
  access_tier                     = "Hot"
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  network_rules {
    default_action = "Deny"
    ip_rules       = [local.st_01.my_ip]
    bypass = [
      "AzureServices",
      "Logging",
      "Metrics"
    ]
  }
  blob_properties {
    change_feed_enabled           = true
    change_feed_retention_in_days = 21
    versioning_enabled            = false
    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "st_local" {
  for_each = {
    for container in local.st_01.containers : container => container
  }
  name               = each.value
  storage_account_id = azurerm_storage_account.st_local.id
}

resource "azurerm_storage_share" "st_local" {
  for_each = {
    for fileshare in local.st_01.fileshares : fileshare => fileshare
  }
  name               = each.value
  storage_account_id = azurerm_storage_account.st_local.id
  quota              = 150
}

resource "azurerm_storage_queue" "st_local" {
  for_each = {
    for queue in local.st_01.queues : queue => queue
  }
  name                 = each.key
  storage_account_name = azurerm_storage_account.st_local.name
}

resource "azurerm_storage_table" "st_local" {
  for_each = {
    for table in local.st_01.tables : table => table
  }
  name                 = each.key
  storage_account_name = azurerm_storage_account.st_local.name
}

resource "azurerm_private_endpoint" "st_local" {
  for_each = {
    for k, pep in local.st_01.private_endpoints : k => pep
  }

  name                          = "pep-${substr(local.st_01.name, 0, length(local.st_01.name) - 2)}${replace(each.key, "_", "-")}${substr(local.st_01.name, length(local.st_01.name) - 2, 2)}"
  location                      = local.location
  tags                          = local.tags
  resource_group_name           = azurerm_resource_group.st_local.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${substr(local.st_01.name, 0, length(local.st_01.name) - 2)}${replace(each.key, "_", "-")}${substr(local.st_01.name, length(local.st_01.name) - 2, 2)}"
  ip_configuration {
    name               = "ipconfig"
    private_ip_address = each.value
    member_name        = each.key
    subresource_name   = each.key
  }
  private_service_connection {
    name                           = "${local.st_01.name}-${replace(each.key, "_", "-")}"
    private_connection_resource_id = azurerm_storage_account.st_local.id
    subresource_names              = [each.key]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "privatelink.${each.key}.core.windows.net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.${each.key}.core.windows.net")].id
    ]
  }
}
