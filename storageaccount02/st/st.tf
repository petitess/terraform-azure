terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "1.2.0"
    }
  }
}

resource "azurerm_storage_account" "st" {
  name                            = var.name
  tags                            = var.tags
  resource_group_name             = var.rgname
  location                        = var.location
  account_replication_type        = var.replication
  account_tier                    = var.tier
  account_kind                    = var.kind
  access_tier                     = "Hot"
  allow_nested_items_to_be_public = true
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = var.public_access
  network_rules {
    default_action = var.public_networks
    bypass = [
      "AzureServices",
      "Logging",
      "Metrics"
    ]
  }
  blob_properties {
    change_feed_enabled           = true
    change_feed_retention_in_days = 21
    versioning_enabled            = var.versioning_enabled
    container_delete_retention_policy {
      days = 7
    }
  }
}

resource "azurerm_storage_container" "container" {
  for_each = {
    for container in var.containers : container.name => container
  }
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.st.name
}

resource "azurerm_storage_share" "share" {
  for_each = {
    for fileshare in var.fileshares : fileshare.name => fileshare
  }
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.st.name
  quota                = each.value.quotaGB
}

resource "azurerm_storage_queue" "queue" {
  for_each = {
    for queue in var.queues : queue => queue
  }
  name                 = each.key
  storage_account_name = azurerm_storage_account.st.name
}

resource "azurerm_storage_table" "table" {
  for_each = {
    for table in var.tables : table => table
  }
  name                 = each.key
  storage_account_name = azurerm_storage_account.st.name
}

resource "azurerm_backup_container_storage_account" "container" {
  resource_group_name = var.rgname
  recovery_vault_name = var.rsvname
  storage_account_id  = azurerm_storage_account.st.id
}

#DOESN´T WORK PROPERLY
resource "azapi_resource" "protectedItems" {
  for_each = {
    for fileshare, i in var.fileshares : fileshare => i
    if i.backup
  }
  type      = "Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-09-01-preview"
  name      = "AzureFileShare;${each.value.name}"
  tags      = var.tags
  parent_id = "${var.rsvid}/backupFabrics/Azure/protectionContainers/storagecontainer;Storage;${var.rgname};${azurerm_storage_account.st.name}"
  body = jsonencode({
    properties : {
      protectedItemType : "AzureFileShareProtectedItem"
      policyId : var.rsvpolicyid
      sourceResourceId : azurerm_storage_account.st.id
    }
  })
}

# resource "azurerm_backup_protected_file_share" "share" {
#   for_each = {
#     for fileshare, i in var.fileshares : fileshare => i
#     if i.backup
#   }
#   resource_group_name       = var.rgname
#   recovery_vault_name       = var.rsvname
#   backup_policy_id          = var.rsvpolicyid
#   source_file_share_name    = each.value.name
#   source_storage_account_id = azurerm_storage_account.st.id
# }