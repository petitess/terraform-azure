data "azurerm_storage_account" "tfstate" {
  resource_group_name = local.st_rg_name
  name                = local.st_name
}

resource "azurerm_private_endpoint" "blob" {
  count                         = local.st_name != "" ? 1 : 0
  name                          = "${local.st_name}-blob-pep"
  location                      = local.location
  tags                          = local.tags
  resource_group_name           = local.st_rg_name
  subnet_id                     = "${data.azurerm_subscription.sub.id}/resourceGroups/${azurerm_resource_group.hub.name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_name}/subnets/snet-pep"
  custom_network_interface_name = "${local.st_name}-blob-nic"
  private_service_connection {
    private_connection_resource_id = data.azurerm_storage_account.tfstate.id
    name                           = "blob-pe"
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  private_dns_zone_group {
    name = "blob"
    private_dns_zone_ids = [
      "${data.azurerm_subscription.sub.id}/resourceGroups/${azurerm_resource_group.dns.name}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
    ]
  }
}
