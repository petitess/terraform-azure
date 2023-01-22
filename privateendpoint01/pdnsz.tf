resource "azurerm_private_dns_zone" "blob" {
  name = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.infra.name
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name = "blob-link"
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  resource_group_name = azurerm_resource_group.infra.name
  virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "file" {
  name = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.infra.name
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name = "file-link"
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  resource_group_name = azurerm_resource_group.infra.name
  virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "queue" {
  name = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.infra.name
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "queue" {
  name = "queue-link"
  private_dns_zone_name = azurerm_private_dns_zone.queue.name
  resource_group_name = azurerm_resource_group.infra.name
  virtual_network_id = azurerm_virtual_network.vnet.id
}

resource "azurerm_private_dns_zone" "table" {
  name = "privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.infra.name
  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "table" {
  name = "table-link"
  private_dns_zone_name = azurerm_private_dns_zone.table.name
  resource_group_name = azurerm_resource_group.infra.name
  virtual_network_id = azurerm_virtual_network.vnet.id
}