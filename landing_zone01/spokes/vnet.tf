resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.prefix}-01"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = azurerm_resource_group.spoke.tags
}

resource "azurerm_virtual_network_peering" "spoke" {
  name                      = "peer-hub-01"
  virtual_network_name      = azurerm_virtual_network.vnet.name
  resource_group_name       = azurerm_resource_group.spoke.name
  remote_virtual_network_id = local.vnet_hub_id
  allow_forwarded_traffic   = true
  use_remote_gateways       = true
}

resource "azurerm_virtual_network_peering" "hub" {
  name                      = "peer-${var.prefix}-01"
  virtual_network_name      = local.vnet_hub_name
  resource_group_name       = local.vnet_hub_rg_name
  provider                  = azurerm.hub
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
  allow_forwarded_traffic   = false
  allow_gateway_transit     = true
}

resource "azurerm_firewall_policy_rule_collection_group" "spoke" {
  name               = "${var.spoke}-${var.env}"
  priority           = 100
  firewall_policy_id = local.firewall_hub_id
  dynamic "network_rule_collection" {
    for_each = var.firewall.network_rule_collection
    content {
      action   = network_rule_collection.value.action
      name     = network_rule_collection.value.collection_name
      priority = network_rule_collection.value.priority
      rule {
        name                  = network_rule_collection.value.rule_name
        protocols             = network_rule_collection.value.protocols
        source_addresses      = network_rule_collection.value.source_addresses
        source_ip_groups      = network_rule_collection.value.source_ip_groups
        destination_addresses = network_rule_collection.value.destination_addresses
        destination_ports     = network_rule_collection.value.destination_ports
      }
    }
  }

  dynamic "application_rule_collection" {
    for_each = var.firewall.application_rule_collection
    content {
      action   = application_rule_collection.value.action
      name     = application_rule_collection.value.collection_name
      priority = application_rule_collection.value.priority
      rule {
        name                  = application_rule_collection.value.rule_name
        destination_fqdns     = application_rule_collection.value.destination_fqdns
        destination_addresses = application_rule_collection.value.destination_addresses
        destination_fqdn_tags = application_rule_collection.value.destination_fqdn_tags
        destination_urls      = application_rule_collection.value.destination_urls
        source_addresses      = application_rule_collection.value.source_addresses
        source_ip_groups      = application_rule_collection.value.source_ip_groups
        terminate_tls         = application_rule_collection.value.terminate_tls
        web_categories        = application_rule_collection.value.web_categories
        protocols {
          type = application_rule_collection.value.protocol_type
          port = application_rule_collection.value.protocol_port
        }
      }
    }
  }
}
