resource "azurerm_virtual_network" "vnet" {
  name = "vnet01"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = azurerm_resource_group.main.tags
}

resource "azurerm_subnet" "subnet" {
  name = "snet-core01"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.main.name
  address_prefixes = [ "10.0.5.0/24" ]
}

resource "azurerm_public_ip" "pip" {
    name = "mypip01"
    location = azurerm_resource_group.main.location
    tags = azurerm_resource_group.main.tags
    resource_group_name = azurerm_resource_group.main.name
    allocation_method = "Static"
}

resource "azurerm_network_interface" "vmnic01" {
  name = "vmnic01"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = azurerm_resource_group.main.tags
  ip_configuration {
    primary = true 
    name = "config01"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}