locals {
  container_list = flatten([
    for key, value in var.st_list : [
      for c in value.containers :
      {
        container_name = c
        st_name        = value.name
      }
    ] if value.containers != null
  ])

  container_list_map = {
    for k, v in local.container_list : k => v
  }

  shares_list = flatten([
    for key, value in var.st_list : [
      for sh in value.shares :
      {
        share_name = sh
        st_name    = value.name
      }
    ] if value.shares != null
  ])

  shares_list_map = {
    for k, v in local.shares_list : k => v
  }

  queues_list = flatten([
    for key, value in var.st_list : [
      for q in value.queues :
      {
        queue_name = q
        st_name    = value.name
      }
    ] if value.queues != null
  ])

  queues_list_map = {
    for k, v in local.queues_list : k => v
  }

  table_list = flatten([
    for key, value in var.st_list : [
      for t in value.tables :
      {
        table_name = t
        st_name    = value.name
      }
    ] if value.tables != null
  ])

  table_list_map = {
    for k, v in local.table_list : k => v
  }

  pep_list = flatten([
    for key, value in var.st_list : [
      for type, ip in value.private_endpoints :
      {
        ip      = ip
        type    = type
        st_name = value.name
        rg_name = value.rg_name != null ? value.rg_name : azurerm_resource_group.st_list_common.name
      }
    ] if value.private_endpoints != null
  ])

  pep_list_map = {
    for k, v in local.pep_list : k => v
    if v.ip != null
  }
}

resource "azurerm_resource_group" "st_list_common" {
  name     = "rg-st-list-${var.affix}-01"
  location = local.location
  tags     = local.tags
}

resource "azurerm_resource_group" "st_list" {
  for_each = {
    for s in distinct(flatten(var.st_list.*.rg_name)) : s => s
    if s != null
  }
  name     = each.value
  location = local.location
  tags     = local.tags
}

resource "azurerm_storage_account" "st_list" {
  for_each = {
    for s in var.st_list : s.name => s
  }
  depends_on                      = [azurerm_resource_group.st_list]
  name                            = each.value.name
  tags                            = local.tags
  resource_group_name             = each.value.rg_name == null ? azurerm_resource_group.st_list_common.name : each.value.rg_name
  location                        = local.location
  account_replication_type        = each.value.account_replication_type
  account_tier                    = "Standard"
  account_kind                    = "StorageV2"
  access_tier                     = each.value.access_tier
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  network_rules {
    default_action = "Deny"
    ip_rules       = each.value.allowed_ips
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

resource "azurerm_storage_container" "st_list" {
  for_each           = local.container_list_map
  name               = each.value.container_name
  storage_account_id = azurerm_storage_account.st_list[each.value.st_name].id
}

resource "azurerm_storage_share" "st_list" {
  for_each           = local.shares_list_map
  name               = each.value.share_name
  storage_account_id = azurerm_storage_account.st_list[each.value.st_name].id
  quota              = 150
}

resource "azurerm_storage_queue" "st_list" {
  for_each             = local.queues_list_map
  name                 = each.value.queue_name
  storage_account_name = each.value.st_name
  depends_on           = [azurerm_storage_account.st_list]
}

resource "azurerm_storage_table" "st_list" {
  for_each             = local.table_list_map
  name                 = each.value.table_name
  storage_account_name = each.value.st_name
  depends_on           = [azurerm_storage_account.st_list]
}

resource "azurerm_private_endpoint" "st_list_pep" {
  for_each                      = local.pep_list_map
  name                          = "pep-${substr(each.value.st_name, 0, length(each.value.st_name) - 2)}${replace(each.value.type, "_", "-")}${substr(each.value.st_name, length(each.value.st_name) - 2, 2)}"
  location                      = local.location
  tags                          = local.tags
  resource_group_name           = each.value.rg_name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${substr(each.value.st_name, 0, length(each.value.st_name) - 2)}${replace(each.value.type, "_", "-")}${substr(each.value.st_name, length(each.value.st_name) - 2, 2)}"
  ip_configuration {
    name               = "ipconfig"
    private_ip_address = each.value.ip
    member_name        = each.value.type
    subresource_name   = each.value.type
  }
  private_service_connection {
    name                           = "${each.value.st_name}-${replace(each.value.type, "_", "-")}"
    private_connection_resource_id = azurerm_storage_account.st_list[each.value.st_name].id
    subresource_names              = [each.value.type]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "privatelink.${each.value.type}.core.windows.net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.${each.value.type}.core.windows.net")].id
    ]
  }
}
