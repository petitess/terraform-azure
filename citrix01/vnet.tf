resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  address_space       = var.vnet.address_space
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name
  tags                = azurerm_resource_group.infra.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
  }
  name                 = each.value.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.infra.name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_nat_gateway" "nat" {
  count               = var.natgatewaysubnets != [] ? 1 : 0
  name                = "ng-${var.prefix}01"
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name
  tags                = azurerm_resource_group.infra.tags
  sku_name            = "Standard"
}

resource "azurerm_public_ip" "natpip" {
  count               = var.natgatewaysubnets != [] ? 1 : 0
  name                = "${azurerm_nat_gateway.nat[0].name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.infra.name
  tags                = var.tags
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_nat_gateway_public_ip_association" "pipa" {
  count                = var.natgatewaysubnets != [] ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.nat[0].id
  public_ip_address_id = azurerm_public_ip.natpip[0].id
}

resource "azurerm_subnet_nat_gateway_association" "nata" {
  for_each = {
    for subnet in var.natgatewaysubnets : subnet => subnet
    if var.natgatewaysubnets != []
  }
  nat_gateway_id = azurerm_nat_gateway.nat[0].id
  subnet_id      = "${data.azurerm_subscription.sub.id}/resourceGroups/${azurerm_resource_group.infra.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.vnet.name}/subnets/${each.key}"
}

resource "azurerm_network_security_group" "nsg" {
  for_each = {
    for nsg in var.nsg : nsg.name => nsg
  }
  name                = each.value.name
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.infra.name
  dynamic "security_rule" {
    for_each = each.value.security_rule
    content {
      access                                     = security_rule.value.access
      description                                = security_rule.value.description
      destination_address_prefix                 = security_rule.value.destination_address_prefix
      destination_address_prefixes               = security_rule.value.destination_address_prefixes
      destination_application_security_group_ids = security_rule.value.destination_application_security_group_ids
      destination_port_range                     = security_rule.value.destination_port_range
      destination_port_ranges                    = security_rule.value.destination_port_ranges
      direction                                  = security_rule.value.direction
      name                                       = security_rule.value.name
      priority                                   = security_rule.value.priority
      protocol                                   = security_rule.value.protocol
      source_address_prefix                      = security_rule.value.source_address_prefix
      source_address_prefixes                    = security_rule.value.source_address_prefixes
      source_application_security_group_ids      = security_rule.value.source_application_security_group_ids
      source_port_range                          = security_rule.value.source_port_range
      source_port_ranges                         = security_rule.value.source_port_ranges
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  for_each = {
    for nsg in var.nsg : nsg.name => nsg
  }
  depends_on = [
    azurerm_virtual_network.vnet
  ]
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
  subnet_id                 = "${data.azurerm_subscription.sub.id}/resourceGroups/${azurerm_resource_group.infra.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.vnet.name}/subnets/${each.value.subnetname}"
}
