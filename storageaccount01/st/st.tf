resource "azurerm_storage_account" "st" {
    name = var.name
    tags = var.tags
    resource_group_name = var.rgname
    location = var.location
    account_replication_type =  var.replication
    account_tier = var.tier
    account_kind = var.kind
    access_tier = "Hot"
    allow_nested_items_to_be_public = true
    enable_https_traffic_only =  true
    min_tls_version = "TLS1_2"
    public_network_access_enabled = var.public_access
    network_rules {
        default_action = var.public_networks
        bypass = [ 
            "AzureServices",
            "Logging",
            "Metrics"
            ]
    }
    blob_properties {
       change_feed_enabled = true
       change_feed_retention_in_days = 21
       versioning_enabled = var.versioning_enabled
       container_delete_retention_policy {
         days = 7
       }
    }
}

resource "azurerm_storage_container" "container" {
    for_each = {
    for container in var.containers : container.name => container
    }
    name = each.value.name
    storage_account_name = azurerm_storage_account.st.name
}

resource "azurerm_storage_share" "share" {
    for_each = {
    for fileshare in var.fileshares : fileshare.name => fileshare
    }
  name = each.value.name
  storage_account_name = azurerm_storage_account.st.name
  quota = 150
}

resource "azurerm_storage_queue" "queue" {
    for_each = {
    for queue in var.queues : queue => queue
    }
    name = each.key
    storage_account_name = azurerm_storage_account.st.name
}

resource "azurerm_storage_table" "table" {
    for_each = {
        for table in var.tables : table => table
        }
    name = each.key
    storage_account_name = azurerm_storage_account.st.name
}