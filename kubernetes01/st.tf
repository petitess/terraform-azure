locals {
  st_name    = "staks123321${var.env}01"
  containers = []
  fileshares = ["node01"]
  queues     = []
  tables     = []
  st_peps    = ["file"]
  my_ip = "1.150.104.23"
}

resource "azurerm_storage_account" "aks" {
  name                            = local.st_name
  tags                            = local.tags
  resource_group_name             = azurerm_resource_group.aks.name
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
    ip_rules = [ local.my_ip ]
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

resource "azurerm_storage_container" "container" {
  for_each = {
    for container in local.containers : container => container
  }
  name               = each.value
  storage_account_id = azurerm_storage_account.aks.id
}

resource "azurerm_storage_share" "share" {
  for_each = {
    for fileshare in local.fileshares : fileshare => fileshare
  }
  name               = each.value
  storage_account_id = azurerm_storage_account.aks.id
  quota              = 150
}

resource "azurerm_storage_queue" "queue" {
  for_each = {
    for queue in local.queues : queue => queue
  }
  name                 = each.key
  storage_account_name = azurerm_storage_account.aks.name
}

resource "azurerm_storage_table" "table" {
  for_each = {
    for table in local.tables : table => table
  }
  name                 = each.key
  storage_account_name = azurerm_storage_account.aks.name
}

resource "azurerm_private_endpoint" "st_pep" {
  for_each = {
    for pep in local.st_peps : pep => pep
  }

  name                          = "pep-${substr(local.st_name, 0, length(local.st_name) - 2)}${replace(each.value, "_", "-")}${substr(local.st_name, length(local.st_name) - 2, 2)}"
  location                      = local.location
  tags                          = local.tags
  resource_group_name           = azurerm_resource_group.aks.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${substr(local.st_name, 0, length(local.st_name) - 2)}${replace(each.value, "_", "-")}${substr(local.st_name, length(local.st_name) - 2, 2)}"

  private_service_connection {
    name                           = "${local.st_name}-${replace(each.value, "_", "-")}"
    private_connection_resource_id = azurerm_storage_account.aks.id
    subresource_names              = [each.value]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "privatelink.${each.value}.core.windows.net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.${each.value}.core.windows.net")].id
    ]
  }
}
