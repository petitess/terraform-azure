locals {
  stname = "stdatalakesystemtest01"
}

resource "azurerm_storage_account" "storage_account" {
  name                              = local.stname
  resource_group_name               = azurerm_resource_group.rg.name
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


resource "azurerm_private_endpoint" "blob_pe" {

  name = "pep-blob-${local.stname}"

  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-pep-blob-${local.stname}"
  private_service_connection {
    name                           = "${local.stname}-blob-privateserviceconnection"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}
