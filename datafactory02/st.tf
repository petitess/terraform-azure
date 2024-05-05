locals {
  st_name = "stdatalakesystemtest01"
  st_peps = [
    "blob",
    "dfs",
    "web"
  ]
}

resource "azurerm_storage_account" "storage_account" {
  name                              = local.st_name
  resource_group_name               = azurerm_resource_group.st.name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  access_tier                       = "Hot"
  allow_nested_items_to_be_public   = false
  is_hns_enabled                    = true
  min_tls_version                   = "TLS1_2"
  account_kind                      = "StorageV2"
  enable_https_traffic_only         = true
  public_network_access_enabled     = false
  infrastructure_encryption_enabled = true
  large_file_share_enabled          = false
  sftp_enabled                      = true
  shared_access_key_enabled         = false

  tags = var.tags
}

resource "azurerm_storage_account_network_rules" "storage_account" {
  storage_account_id = azurerm_storage_account.storage_account.id

  default_action             = "Deny"
  ip_rules                   = []
  virtual_network_subnet_ids = []
  bypass                     = ["AzureServices"]
}

resource "azurerm_storage_data_lake_gen2_filesystem" "synw" {
  name = "container-filesystem-synw-01"
  storage_account_id = azurerm_storage_account.storage_account.id  
}

resource "azurerm_private_endpoint" "st_pep" {
  for_each = {
    for pep in local.st_peps : pep => pep
  }

  name                          = "pep-${substr(local.st_name, 0, length(local.st_name) - 2)}${replace(each.value, "_", "-")}${substr(local.st_name, length(local.st_name) - 2, 2)}"
  location                      = var.location
  tags                          = var.tags
  resource_group_name           = azurerm_resource_group.st.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${substr(local.st_name, 0, length(local.st_name) - 2)}${replace(each.value, "_", "-")}${substr(local.st_name, length(local.st_name) - 2, 2)}"

  private_service_connection {
    name                           = "${local.st_name}-${replace(each.value, "_", "-")}"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = [each.value]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "privatelink.${each.value}.core.windows.net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(var.pdnsz, "privatelink.${each.value}.core.windows.net")].id
    ]
  }
}
