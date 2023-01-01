resource "azurerm_virtual_network" "vnet" {
  name = var.vnet.name
  address_space = var.vnet.address_space
  location = azurerm_resource_group.rginfra.location
  resource_group_name = azurerm_resource_group.rginfra.name
  tags = azurerm_resource_group.rginfra.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = {
  for subnet in var.subnets : subnet.name => subnet
  }
  name = each.value.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name = azurerm_resource_group.rginfra.name
  address_prefixes = each.value.address_prefixes
}

resource "azurerm_nat_gateway" "nat" {
  count = var.natgatewaysubnets != [] ? 1 : 0
  name = "ng-${var.prefix}01"
  location = azurerm_resource_group.rginfra.location
  resource_group_name = azurerm_resource_group.rginfra.name
  tags = azurerm_resource_group.rginfra.tags
  sku_name = "Standard"
}

resource "azurerm_public_ip" "natpip" {
  count = var.natgatewaysubnets != [] ? 1 : 0 
  name = "${azurerm_nat_gateway.nat[0].name}-pip"
  location = var.location
  resource_group_name = azurerm_resource_group.rginfra.name
  tags = var.tags
  sku = "Standard"
  allocation_method = "Static"
}

resource "azurerm_nat_gateway_public_ip_association" "pipa" {
  count = var.natgatewaysubnets != [] ? 1 : 0 
  nat_gateway_id = azurerm_nat_gateway.nat[0].id
  public_ip_address_id = azurerm_public_ip.natpip[0].id
}

resource "azurerm_subnet_nat_gateway_association" "nata" {
  for_each =  {
  for subnet in var.natgatewaysubnets : subnet => subnet
  if var.natgatewaysubnets != [] 
  } 
  nat_gateway_id = azurerm_nat_gateway.nat[0].id
  subnet_id = "${data.azurerm_subscription.sub.id}/resourceGroups/${azurerm_resource_group.rginfra.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.vnet.name}/subnets/${each.key}"
}