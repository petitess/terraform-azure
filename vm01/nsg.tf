resource "azurerm_network_security_group" "AzureBastion" {
  name = "nsg-${azurerm_subnet.subnets[var.subnets[2].name].name}"
  location = azurerm_resource_group.rginfra.location
  tags = azurerm_resource_group.rginfra.tags
  resource_group_name = azurerm_resource_group.rginfra.name
  security_rule = var.nsg-AzureBastion
}

resource "azurerm_subnet_network_security_group_association" "AzureBastion" {
  network_security_group_id = azurerm_network_security_group.AzureBastion.id
  subnet_id = azurerm_subnet.subnets[var.subnets[2].name].id
}

resource "azurerm_network_security_group" "nsg-pe" {
  name = "nsg-${azurerm_subnet.subnets[var.subnets[3].name].name}"
  location = azurerm_resource_group.rginfra.location
  tags = azurerm_resource_group.rginfra.tags
  resource_group_name = azurerm_resource_group.rginfra.name
  security_rule = var.nsg-pe-01
}

resource "azurerm_subnet_network_security_group_association" "pe" {
  network_security_group_id = azurerm_network_security_group.nsg-pe.id
  subnet_id = azurerm_subnet.subnets[var.subnets[3].name].id
}

resource "azurerm_network_security_group" "nsg-core" {
    name = "nsg-${azurerm_subnet.subnets[var.subnets[4].name].name}"
    location = azurerm_resource_group.rginfra.location
    tags = azurerm_resource_group.rginfra.tags
    resource_group_name = azurerm_resource_group.rginfra.name
    security_rule = var.nsg-core-01
}

resource "azurerm_subnet_network_security_group_association" "core" {
  network_security_group_id = azurerm_network_security_group.nsg-core.id
  subnet_id = azurerm_subnet.subnets[var.subnets[4].name].id
}

resource "azurerm_network_security_group" "nsg-mgmt" {
  name = "nsg-${azurerm_subnet.subnets[var.subnets[5].name].name}"
  location = azurerm_resource_group.rginfra.location
  tags = azurerm_resource_group.rginfra.tags
  resource_group_name = azurerm_resource_group.rginfra.name
  security_rule = var.nsg-mgmt-01
}

resource "azurerm_subnet_network_security_group_association" "mgmt" {
  network_security_group_id = azurerm_network_security_group.nsg-mgmt.id
  subnet_id = azurerm_subnet.subnets[var.subnets[5].name].id
}

resource "azurerm_network_security_group" "nsg-sql" {
  name = "nsg-${azurerm_subnet.subnets[var.subnets[6].name].name}"
  location = azurerm_resource_group.rginfra.location
  tags = azurerm_resource_group.rginfra.tags
  resource_group_name = azurerm_resource_group.rginfra.name
  security_rule = var.nsg-sql-01
}

resource "azurerm_subnet_network_security_group_association" "sql" {
  network_security_group_id = azurerm_network_security_group.nsg-sql.id
  subnet_id = azurerm_subnet.subnets[var.subnets[6].name].id
}

resource "azurerm_network_security_group" "nsg-app" {
  name = "nsg-${azurerm_subnet.subnets[var.subnets[7].name].name}"
  location = azurerm_resource_group.rginfra.location
  tags = azurerm_resource_group.rginfra.tags
  resource_group_name = azurerm_resource_group.rginfra.name
  security_rule = var.nsg-app-01
}

resource "azurerm_subnet_network_security_group_association" "app" {
  network_security_group_id = azurerm_network_security_group.nsg-app.id
  subnet_id = azurerm_subnet.subnets[var.subnets[7].name].id
}

resource "azurerm_network_security_group" "nsg-web" {
  name = "nsg-${azurerm_subnet.subnets[var.subnets[8].name].name}"
  location = azurerm_resource_group.rginfra.location
  tags = azurerm_resource_group.rginfra.tags
  resource_group_name = azurerm_resource_group.rginfra.name
  security_rule = var.nsg-web-01
}

resource "azurerm_subnet_network_security_group_association" "web" {
  network_security_group_id = azurerm_network_security_group.nsg-web.id
  subnet_id = azurerm_subnet.subnets[var.subnets[8].name].id
}