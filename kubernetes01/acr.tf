resource "azurerm_resource_group" "acr" {
  name = "rg-acr-${var.env}-01"
  location = local.location
  tags = local.tags
}

resource "azurerm_container_registry" "acr" {
  name                = "acrboombastic${var.env}01"
  resource_group_name = azurerm_resource_group.acr.name
  location            = azurerm_resource_group.acr.location
  sku                 = "Premium"
  admin_enabled       = false
  tags                = local.tags
}

resource "azurerm_private_endpoint" "acr_pep" {
  name                          = "pep-${azurerm_container_registry.acr.name}"
  location                      = local.location
  resource_group_name           = azurerm_resource_group.acr.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_container_registry.acr.name}"
  private_service_connection {
    name                           = "privateserviceconnection"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
  tags = local.tags
  private_dns_zone_group {
    name = "privatelink.azurecr.io"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.azurecr.io")].id
    ]
  }
}
