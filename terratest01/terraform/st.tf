locals {
  my_containers = flatten([
    for key, value in var.st_map : [
      for c in value.containers != null ? value.containers : [] : {
        container_name = c
        st_name        = value.name
        map_key        = key
      }
    ]
  ])

  my_containers_map = {
    for n, k in local.my_containers : n => k
  }

  my_shares = flatten([
    for key, value in var.st_map : [
      for c in value.shares != null ? value.shares : [] : {
        share_name = c
        st_name    = value.name
        map_key    = key
      }
    ]
  ])

  my_shares_map = {
    for n, k in local.my_shares : n => k
  }

  my_queues = flatten([
    for key, value in var.st_map : [
      for c in value.queues != null ? value.queues : [] : {
        queue_name = c
        st_name    = value.name
        map_key    = key
      }
    ]
  ])

  my_queues_map = {
    for n, k in local.my_queues : n => k
  }

  my_tables = flatten([
    for key, value in var.st_map : [
      for t in value.tables != null ? value.tables : [] : {
        table_name = t
        st_name    = value.name
        map_key    = key
      }
    ]
  ])

  my_tables_map = {
    for n, k in local.my_tables : n => k
  }

  my_pep = flatten([
    for key, value in var.st_map : [
      for type, ip in value.private_endpoints != null ? value.private_endpoints : {} : {
        ip      = ip
        type    = type
        st_name = value.name
        st_key  = key
        rg_name = value.rg_name != null ? value.rg_name : azurerm_resource_group.st_map_common.name
      }
    ]
  ])

  my_pep_map = {
    for n, k in local.my_pep : n => k
    if k.ip != null
  }
}

resource "azurerm_resource_group" "st_map_common" {
  name     = "rg-st-map-${local.prefix}-01"
  location = local.location
  tags     = local.tags
}

resource "azurerm_resource_group" "st_map" {
  for_each = {
    for s in distinct([for val in var.st_map : val].*.rg_name) : s => s
    if s != null
  }
  name     = each.value
  location = local.location
  tags     = local.tags
}

resource "azurerm_storage_account" "st_map" {
  for_each                        = var.st_map
  depends_on                      = [azurerm_resource_group.st_map]
  name                            = each.value.name
  tags                            = local.tags
  resource_group_name             = each.value.rg_name == null ? azurerm_resource_group.st_map_common.name : each.value.rg_name
  location                        = local.location
  account_replication_type        = each.value.account_replication_type
  account_tier                    = "Standard"
  account_kind                    = "StorageV2"
  access_tier                     = each.value.access_tier
  allow_nested_items_to_be_public = true
  min_tls_version                 = try(each.value.min_tls_version, "TLS1_2")
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

  lifecycle {
    precondition {
      condition     = each.value.account_kind == "Storage" || each.value.account_kind == "StorageV2" || each.value.account_kind == "BlobStorage" || each.value.account_kind == "BlockBlobStorage" || each.value.account_kind == "FileStorage"
      error_message = "Valid options for account kind are StorageV2, Storage, BlobStorage, BlockBlobStorage, FileStorage."
    }
    precondition {
      condition     = each.value.access_tier == "Hot" || each.value.access_tier == "Cool"
      error_message = "Account access tier supports Hot or Cool."
    }
    precondition {
      condition     = try(each.value.min_tls_version, "TLS1_2") == "TLS1_2"
      error_message = "TLS version must be 1.2"
    }
    precondition {
      condition     = length(each.value.name) < 25
      error_message = "The name ${each.value.name} is too long"
    }
    precondition {
      condition     = startswith(each.value.name, "st")
      error_message = "The name ${each.value.name} must start with 'st'"
    }
  }
}

resource "azurerm_storage_container" "st_map" {
  for_each           = local.my_containers_map
  name               = each.value.container_name
  storage_account_id = azurerm_storage_account.st_map[each.value.map_key].id
}

resource "azurerm_storage_share" "st_map" {
  for_each           = local.my_shares_map
  name               = each.value.share_name
  storage_account_id = azurerm_storage_account.st_map[each.value.map_key].id
  quota              = 150
}

resource "azurerm_storage_queue" "st_map" {
  for_each             = local.my_queues_map
  name                 = each.value.queue_name
  storage_account_name = each.value.st_name
  depends_on           = [azurerm_storage_account.st_map]
}

resource "azurerm_storage_table" "st_map" {
  for_each             = local.my_tables_map
  name                 = each.value.table_name
  storage_account_name = each.value.st_name
  depends_on           = [azurerm_storage_account.st_map]
}

# resource "azurerm_private_endpoint" "st_map_pep" {
#   for_each                      = local.my_pep_map
#   name                          = "pep-${substr(each.value.st_name, 0, length(each.value.st_name) - 2)}${replace(each.value.type, "_", "-")}${substr(each.value.st_name, length(each.value.st_name) - 2, 2)}"
#   location                      = local.location
#   tags                          = local.tags
#   resource_group_name           = each.value.rg_name
#   subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
#   custom_network_interface_name = "nic-${substr(each.value.st_name, 0, length(each.value.st_name) - 2)}${replace(each.value.type, "_", "-")}${substr(each.value.st_name, length(each.value.st_name) - 2, 2)}"
#   ip_configuration {
#     name               = "ipconfig"
#     private_ip_address = each.value.ip
#     member_name        = each.value.type
#     subresource_name   = each.value.type
#   }
#   private_service_connection {
#     name                           = "${each.value.st_name}-${replace(each.value.type, "_", "-")}"
#     private_connection_resource_id = azurerm_storage_account.st_map[each.value.st_key].id
#     subresource_names              = [each.value.type]
#     is_manual_connection           = false
#   }

#   private_dns_zone_group {
#     name = "privatelink.${each.value.type}.core.windows.net"
#     private_dns_zone_ids = [
#       azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.${each.value.type}.core.windows.net")].id
#     ]
#   }
# }

output "st_map" {
  value = var.st_map
}
