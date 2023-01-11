resource "azurerm_network_security_group" "nsg" {
  for_each = {
    for nsg in var.nsg : nsg.name => nsg
    }
  name = each.value.name
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rginfra.name
  dynamic "security_rule" {
    for_each = each.value.security_rule
    content {
      access = security_rule.value.access
      description = security_rule.value.description
      destination_address_prefix = security_rule.value.destination_address_prefix
      destination_address_prefixes =security_rule.value.destination_address_prefixes
      destination_application_security_group_ids = security_rule.value.destination_application_security_group_ids
      destination_port_range = security_rule.value.destination_port_range
      destination_port_ranges = security_rule.value.destination_port_ranges
      direction = security_rule.value.direction
      name = security_rule.value.name
      priority = security_rule.value.priority
      protocol = security_rule.value.protocol
      source_address_prefix = security_rule.value.source_address_prefix
      source_address_prefixes = security_rule.value.source_address_prefixes
      source_application_security_group_ids = security_rule.value.source_application_security_group_ids
      source_port_range = security_rule.value.source_port_range
      source_port_ranges = security_rule.value.source_port_ranges       
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
  subnet_id = "${data.azurerm_subscription.sub.id}/resourceGroups/${azurerm_resource_group.rginfra.name}/providers/Microsoft.Network/virtualNetworks/${azurerm_virtual_network.vnet.name}/subnets/${each.value.subnetname}" 
}