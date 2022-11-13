resource "azurerm_network_security_group" "AzureBastion" {
  name = "nsg-${azurerm_subnet.AzureBastion.name}"
  location = azurerm_resource_group.rginfra.location
  tags = azurerm_resource_group.rginfra.tags
  resource_group_name = azurerm_resource_group.rginfra.name
  security_rule =  [ {
    access =  "Allow"
    description = "Allow Monitor"
    destination_address_prefix = "*"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = "10050"
    destination_port_ranges = []
    direction = "Inbound"
    name = "Allow_Inbound_Monitor"
    priority = 500
    protocol = "*"
    source_address_prefix = "10.10.7.11/32"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  },
  {
    access =  "Allow"
    description = "Allow_Inbound_Https"
    destination_address_prefix = "*"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = "443"
    destination_port_ranges = []
    direction = "Inbound"
    name = "Allow_Inbound_Https"
    priority = 600
    protocol = "Tcp"
    source_address_prefix = "Internet"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  },
  {
    access =  "Allow"
    description = "Allow_Inbound_GatewayManager"
    destination_address_prefix = "*"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = "443"
    destination_port_ranges = []
    direction = "Inbound"
    name = "Allow_Inbound_GatewayManager"
    priority = 700
    protocol = "Tcp"
    source_address_prefix = "GatewayManager"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  },
  {
    access =  "Allow"
    description = "Allow_Inbound_AzureLoadBalancer"
    destination_address_prefix = "*"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = "443"
    destination_port_ranges = []
    direction = "Inbound"
    name = "Allow_Inbound_AzureLoadBalancer"
    priority = 800
    protocol = "Tcp"
    source_address_prefix = "AzureLoadBalancer"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  },
  {
    access =  "Allow"
    description = "Allow_Inbound_BastionHost"
    destination_address_prefix = "VirtualNetwork"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = ""
    destination_port_ranges = [
        "8080",
        "5701"
    ]
    direction = "Inbound"
    name = "Allow_Inbound_BastionHost"
    priority = 900
    protocol = "*"
    source_address_prefix = "VirtualNetwork"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  },
  {
    access =  "Deny"
    description = "Deny_Inbound_All"
    destination_address_prefix = "*"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = "*"
    destination_port_ranges = []
    direction = "Inbound"
    name = "Deny_Inbound_All"
    priority = 4096
    protocol = "*"
    source_address_prefix = "*"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  },
  {
    access =  "Allow"
    description = "Allow_Outbound_RdpSsh"
    destination_address_prefix = "VirtualNetwork"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = ""
    destination_port_ranges = [
        "22",
        "3389"
    ]
    direction = "Outbound"
    name = "Allow_Outbound_RdpSsh"
    priority = 700
    protocol = "*"
    source_address_prefix = "*"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  },
  {
    access =  "Allow"
    description = "Allow_Outbound_AzureCloud"
    destination_address_prefix = "AzureCloud"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = "443"
    destination_port_ranges = []
    direction = "Outbound"
    name = "Allow_Outbound_AzureCloud"
    priority = 800
    protocol = "Tcp"
    source_address_prefix = "*"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  },
  {
    access =  "Allow"
    description = "Allow_Outbound_BastionHost"
    destination_address_prefix = "VirtualNetwork"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = ""
    destination_port_ranges = [
        "8080",
        "5701"
    ]
    direction = "Outbound"
    name = "Allow_Outbound_BastionHost"
    priority = 900
    protocol = "Tcp"
    source_address_prefix = "VirtualNetwork"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  },
  {
    access =  "Allow"
    description = "Allow_Outbound_SessionInformation"
    destination_address_prefix = "Internet"
    destination_address_prefixes = []
    destination_application_security_group_ids = []
    destination_port_range = "80"
    destination_port_ranges = []
    direction = "Outbound"
    name = "Allow_Outbound_SessionInformation"
    priority = 1000
    protocol = "*"
    source_address_prefix = "*"
    source_address_prefixes = []
    source_application_security_group_ids = []
    source_port_range = "*"
    source_port_ranges = []
  }
   ]
}

resource "azurerm_subnet_network_security_group_association" "AzureBastion" {
  network_security_group_id = azurerm_network_security_group.AzureBastion.id
  subnet_id = azurerm_subnet.AzureBastion.id
}

resource "azurerm_network_security_group" "core" {
    name = "nsg-${azurerm_subnet.core.name}"
    location = azurerm_resource_group.rginfra.location
    tags = azurerm_resource_group.rginfra.tags
    resource_group_name = azurerm_resource_group.rginfra.name
    security_rule = [ {
      access = "Allow"
      description = ""
      destination_address_prefix = "*"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = ""
      destination_port_ranges = [
        "22",
        "3389"
      ]
      direction = "Inbound"
      name = "Allow_Inbound_Bastion"
      priority = 100
      protocol = "*"
      source_address_prefix = "10.10.2.0/24"
      source_address_prefixes = []
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    },
    {
      access = "Allow"
      description = ""
      destination_address_prefix = "*"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = "*"
      destination_port_ranges = []
      direction = "Inbound"
      name = "Allow_Inbound_ICMP"
      priority = 200
      protocol = "Icmp"
      source_address_prefix = "10.10.5.0/24"
      source_address_prefixes = []
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    },
    {
      access = "Allow"
      description = ""
      destination_address_prefix = "*"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = ""
      destination_port_ranges = [
        "22",
        "80",
        "135",
        "139",
        "443",
        "445",
        "1433",
        "3389",
        "5986"
      ]
      direction = "Inbound"
      name = "Allow_Inbound_Mgmt"
      priority = 300
      protocol = "*"
      source_address_prefix = "10.10.5.0/24"
      source_address_prefixes = []
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    },
     {
      access = "Allow"
      description = ""
      destination_address_prefix = "*"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = ""
      destination_port_ranges = [
        "53",
        "80",
        "88",
        "123",
        "135",
        "137-139",
        "389",
        "445",
        "464",
        "636",
        "3268-3269",
        "5722",
        "9389",
        "49152-65535"
      ]
      direction = "Inbound"
      name = "Allow_Inbound_ActiveDirectory"
      priority = 400
      protocol = "*"
      source_address_prefix = ""
      source_address_prefixes = [
        "10.10.4.0/24",
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24",
        "10.10.8.0/24",
        "10.10.9.0/24"
      ]
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    },
    {
      access = "Allow"
      description = ""
      destination_address_prefix = "*"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = "10050"
      destination_port_ranges = []
      direction = "Inbound"
      name = "Allow_Inbound_Monitor"
      priority = 500
      protocol = "*"
      source_address_prefix = "10.10.7.11/32"
      source_address_prefixes = []
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    },
    {
      access = "Deny"
      description = ""
      destination_address_prefix = "*"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = "*"
      destination_port_ranges = []
      direction = "Inbound"
      name = "Deny_Inbound_All"
      priority = 4000
      protocol = "*"
      source_address_prefix = "*"
      source_address_prefixes = []
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    },
    {
      access = "Allow"
      description = ""
      destination_address_prefix = "*"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = ""
      destination_port_ranges = [
        "53",
        "80",
        "88",
        "123",
        "135",
        "137-139",
        "389",
        "445",
        "464",
        "636",
        "3268-3269",
        "5722",
        "9389",
        "49152-65535"
      ]
      direction = "Outbound"
      name = "Allow_Outbound_ActiveDirectory"
      priority = 400
      protocol = "*"
      source_address_prefix = ""
      source_address_prefixes = [
        "10.10.4.0/24",
        "10.10.5.0/24",
        "10.10.6.0/24",
        "10.10.7.0/24",
        "10.10.8.0/24",
        "10.10.9.0/24"
      ]
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    },
    {
      access = "Allow"
      description = ""
      destination_address_prefix = "10.10.7.11/32"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = "10051"
      destination_port_ranges = []
      direction = "Outbound"
      name = "Allow_Outbound_Monitor"
      priority = 500
      protocol = "*"
      source_address_prefix = "*"
      source_address_prefixes = []
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    },
    {
      access = "Allow"
      description = ""
      destination_address_prefix = "Internet"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = "*"
      destination_port_ranges = []
      direction = "Outbound"
      name = "Allow_Outbound_Internet"
      priority = 4000
      protocol = "*"
      source_address_prefix = "*"
      source_address_prefixes = []
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    },
    {
      access = "Allow"
      description = ""
      destination_address_prefix = "*"
      destination_address_prefixes = []
      destination_application_security_group_ids = []
      destination_port_range = "*"
      destination_port_ranges = []
      direction = "Outbound"
      name = "Deny_Outbound_All"
      priority = 4096
      protocol = "*"
      source_address_prefix = "*"
      source_address_prefixes = []
      source_application_security_group_ids = []
      source_port_range = "*"
      source_port_ranges = []
    }
     ]
}

resource "azurerm_subnet_network_security_group_association" "core" {
  network_security_group_id = azurerm_network_security_group.core.id
  subnet_id = azurerm_subnet.core.id
}