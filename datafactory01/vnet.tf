resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet.name
  address_space       = var.vnet.address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
  }
  name                 = each.value.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = length(each.value.delegations) != 0 ? each.value.delegations : []

    content {
      name = lower(replace(delegation.value, "/[./]/", "_"))
      service_delegation {
        name = delegation.value
      }
    }
  }

  lifecycle {
    ignore_changes = [delegation[0].service_delegation[0].actions]
  }
}

resource "azurerm_nat_gateway" "nat" {
  count               = var.natgatewaysubnets != [] ? 1 : 0
  name                = "ng-${var.prefix}01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = azurerm_resource_group.rg.tags
  sku_name            = "Standard"
}

resource "azurerm_public_ip" "natpip" {
  count               = var.natgatewaysubnets != [] ? 1 : 0
  name                = "${azurerm_nat_gateway.nat[0].name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
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
  subnet_id      = azurerm_subnet.subnets[each.key].id
}

resource "azurerm_network_security_group" "nsg" {
  for_each = {
    for nsg in var.nsg : nsg.name => nsg
  }
  name                = each.value.name
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.rg.name
  dynamic "security_rule" {
    for_each = each.value.security_rule
    content {
      access                                     = security_rule.value.access
      description                                = try(security_rule.value.description, security_rule.value.name)
      destination_address_prefix                 = try(security_rule.value.destination_address_prefix, null)
      destination_address_prefixes               = try(security_rule.value.destination_address_prefixes, null)
      destination_application_security_group_ids = try(security_rule.value.destination_application_security_group_ids, null)
      destination_port_range                     = try(security_rule.value.destination_port_range, null)
      destination_port_ranges                    = try(security_rule.value.destination_port_ranges, null)
      direction                                  = security_rule.value.direction
      name                                       = security_rule.value.name
      priority                                   = security_rule.value.priority
      protocol                                   = security_rule.value.protocol
      source_address_prefix                      = try(security_rule.value.source_address_prefix, null)
      source_address_prefixes                    = try(security_rule.value.source_address_prefixes, null)
      source_application_security_group_ids      = try(security_rule.value.source_application_security_group_ids, null)
      source_port_range                          = try(security_rule.value.source_port_range, null)
      source_port_ranges                         = try(security_rule.value.source_port_ranges, null)
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
  subnet_id                 = azurerm_subnet.subnets[each.value.subnetname].id
}
