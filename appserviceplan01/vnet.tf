resource "azurerm_virtual_network" "vnet" {
  name = "vnet-${var.prefix}01"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.rginfra.location
  resource_group_name = azurerm_resource_group.rginfra.name
  tags = azurerm_resource_group.rginfra.tags
}

resource "azurerm_subnet" "Gateway" {
  name = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = [ "10.0.0.0/24" ]
}

resource "azurerm_subnet" "AzureFirewall" {
  name = "AzureFirewallSubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = [ "10.0.1.0/24" ]
}

resource "azurerm_subnet" "AzureBastion" {
  name = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = [ "10.0.2.0/24" ]
}

resource "azurerm_subnet" "pe" {
  name = "snet-pe-${var.env}-01"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = [ "10.0.3.0/24" ]
}

resource "azurerm_subnet" "core" {
  name = "snet-core-${var.env}-01"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = [ "10.0.4.0/24" ]
}

resource "azurerm_subnet" "mgmt" {
  name = "snet-mgmt-${var.env}-01"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = [ "10.0.5.0/24" ]
}

resource "azurerm_subnet" "sql" {
  name = "snet-sql-${var.env}-01"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = [ "10.0.6.0/24" ]
}

resource "azurerm_subnet" "app" {
  name = "snet-app-${var.env}-01"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = [ "10.0.7.0/24" ]
  delegation {
    name = "serverFarms"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "web" {
  name = "snet-web-${var.env}-01"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = [ "10.0.8.0/24" ]
}