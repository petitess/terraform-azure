resource "azurerm_public_ip" "afw" {
  name                = "pip-afw-${local.prefix}-01"
  tags                = local.tags
  resource_group_name = azurerm_resource_group.hub.name
  location            = local.location
  allocation_method   = "Static"
}


resource "azurerm_firewall" "afw" {
  name                = "afw-${local.prefix}-01"
  tags                = local.tags
  location            = local.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  ip_configuration {
    name                 = "config01"
    public_ip_address_id = azurerm_public_ip.afw.id
    subnet_id            = azurerm_subnet.subnets["AzureFirewallSubnet"].id
  }
  firewall_policy_id = azurerm_firewall_policy.afw.id
}

resource "azurerm_user_assigned_identity" "afw" {
  name                = "id-afw-${local.prefix}-01"
  tags                = local.tags
  resource_group_name = azurerm_resource_group.hub.name
  location            = local.location
}

resource "azurerm_firewall_policy" "afw" {
  name                = "afwp-${local.prefix}-01"
  tags                = local.tags
  location            = local.location
  resource_group_name = azurerm_resource_group.hub.name
  sku                 = "Premium"
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.afw.id]
  }
  threat_intelligence_mode = "Deny"
  dns {
    proxy_enabled = true
  }
  intrusion_detection {
    mode = "Deny"
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "afw" {
  name               = "global"
  priority           = 100
  firewall_policy_id = azurerm_firewall_policy.afw.id
  network_rule_collection {
    action   = "Allow"
    priority = 100
    name     = "private"
    rule {
      name                  = "allow-all-spokes"
      protocols             = ["Any"]
      source_addresses      = ["10.10.0.0/16"]
      source_ip_groups      = []
      destination_addresses = ["10.10.0.0/16"]
      destination_ports     = ["*"]
    }
  }
}
