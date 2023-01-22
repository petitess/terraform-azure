resource "azurerm_private_endpoint" "blob" {
    count = var.peblob ? 1 : 0
    name = "${azurerm_storage_account.st.name}-blob-pe"
    location = var.location
    tags = var.tags
    resource_group_name = var.rgname
    subnet_id = "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rgname}/providers/Microsoft.Network/virtualNetworks/${var.vnetname}/subnets/${var.pesubnet}"
    private_service_connection {
      private_connection_resource_id = azurerm_storage_account.st.id
      name = "blob-pe"
      is_manual_connection = false
      subresource_names = [ "blob" ]
    }
    private_dns_zone_group {
    name = "blob"
      private_dns_zone_ids = [
        "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rgname}/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
      ]
    }
}

resource "azurerm_private_endpoint" "file" {
    count = var.pefile ? 1 : 0
    name = "${azurerm_storage_account.st.name}-file-pe"
    location = var.location
    tags = var.tags
    resource_group_name = var.rgname
    subnet_id = "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rgname}/providers/Microsoft.Network/virtualNetworks/${var.vnetname}/subnets/${var.pesubnet}"
    private_service_connection {
      private_connection_resource_id = azurerm_storage_account.st.id
      name = "file-pe"
      is_manual_connection = false
      subresource_names = [ "file" ]
    }
    private_dns_zone_group {
    name = "file"
      private_dns_zone_ids = [
        "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rgname}/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
      ]
    }
}

resource "azurerm_private_endpoint" "queue" {
    count = var.pequeue ? 1 : 0
    name = "${azurerm_storage_account.st.name}-queue-pe"
    location = var.location
    tags = var.tags
    resource_group_name = var.rgname
    subnet_id = "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rgname}/providers/Microsoft.Network/virtualNetworks/${var.vnetname}/subnets/${var.pesubnet}"
    private_service_connection {
      private_connection_resource_id = azurerm_storage_account.st.id
      name = "queue-pe"
      is_manual_connection = false
      subresource_names = [ "queue" ]
    }
    private_dns_zone_group {
    name = "queue"
      private_dns_zone_ids = [
        "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rgname}/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net"
      ]
    }
}

resource "azurerm_private_endpoint" "table" {
    count = var.petable ? 1 : 0
    name = "${azurerm_storage_account.st.name}-table-pe"
    location = var.location
    tags = var.tags
    resource_group_name = var.rgname
    subnet_id = "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rgname}/providers/Microsoft.Network/virtualNetworks/${var.vnetname}/subnets/${var.pesubnet}"
    private_service_connection {
      private_connection_resource_id = azurerm_storage_account.st.id
      name = "table-pe"
      is_manual_connection = false
      subresource_names = [ "table" ]
    }
    private_dns_zone_group {
    name = "table"
      private_dns_zone_ids = [
        "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rgname}/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net"
      ]
    }
}