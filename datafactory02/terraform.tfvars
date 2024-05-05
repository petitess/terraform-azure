prefix   = "infra-test"
env      = "test"
location = "swedencentral"
my_ip = "188.150.1.1"
orchestration_base_url      = "https://vade-xxxx-portal-api-prod.azurewebsites.net"
automation_base_url         = "https://vade-xxxx-automation-feature-prod.azurewebsites.net"
subid = "x-95aa-fe7e71802e2e"
tenantid = "x-a39a-3fc5167644de"
init_scripts = [
  "/Shared/customer-notebook/init/pylibs-install.sh",
  "/Shared/customer-notebook/init/msodbcsql17-install.sh"
]
tags = {
  Environment = "Test"
  Application = "Infra"
}
vnet = {
  name          = "vnet-infra-test01"
  address_space = ["10.0.0.0/16"]
}
natgatewaysubnets = [
  #"snet-web"
]
subnets = [
  {
    name             = "GatewaySubnet"
    address_prefixes = ["10.0.0.0/24"]
    delegations      = []
  },
  {
    name             = "AzureFirewallSubnet"
    address_prefixes = ["10.0.1.0/24"]
    delegations      = []
  },
  {
    name             = "AzureBastionSubnet"
    address_prefixes = ["10.0.2.0/24"]
    delegations      = []
  },
  {
    name             = "snet-pep"
    address_prefixes = ["10.0.3.0/24"]
    delegations      = []
  },
  {
    name             = "snet-dbw-private"
    address_prefixes = ["10.0.4.0/24"]
    delegations = [
      "Microsoft.Databricks/workspaces"
    ]
  },
  {
    name             = "snet-dbw-public"
    address_prefixes = ["10.0.5.0/24"]
    delegations = [
      "Microsoft.Databricks/workspaces"
    ]
  }
]

nsg = [
  {
    name       = "nsg-AzureBastion"
    subnetname = "AzureBastionSubnet"
    security_rule = [
      {
        access                     = "Allow"
        destination_address_prefix = "*"
        destination_port_range     = "10050" #
        direction                  = "Inbound"
        name                       = "Allow_Inbound_Monitor"
        priority                   = 500
        protocol                   = "*"
        source_address_prefix      = "10.0.7.11/32"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = "Allow_Inbound_Https"
        destination_address_prefix = "*"
        destination_port_range     = "443"
        direction                  = "Inbound"
        name                       = "Allow_Inbound_Https"
        priority                   = 600
        protocol                   = "Tcp"
        source_address_prefix      = "Internet"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = "Allow_Inbound_GatewayManager"
        destination_address_prefix = "*"
        destination_port_range     = "443"
        direction                  = "Inbound"
        name                       = "Allow_Inbound_GatewayManager"
        priority                   = 700
        protocol                   = "Tcp"
        source_address_prefix      = "GatewayManager"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = "Allow_Inbound_AzureLoadBalancer"
        destination_address_prefix = "*"
        destination_port_range     = "443"
        direction                  = "Inbound"
        name                       = "Allow_Inbound_AzureLoadBalancer"
        priority                   = 800
        protocol                   = "Tcp"
        source_address_prefix      = "AzureLoadBalancer"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = "Allow_Inbound_BastionHost"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges = [
          "8080",
          "5701"
        ]
        direction             = "Inbound"
        name                  = "Allow_Inbound_BastionHost"
        priority              = 900
        protocol              = "*"
        source_address_prefix = "VirtualNetwork"
        source_port_range     = "*"
      },
      {
        access                     = "Deny"
        description                = "Deny_Inbound_All"
        destination_address_prefix = "*"
        destination_port_range     = "*"
        direction                  = "Inbound"
        name                       = "Deny_Inbound_All"
        priority                   = 4096
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = "Allow_Outbound_RdpSsh"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges = [
          "22",
          "3389"
        ]
        direction             = "Outbound"
        name                  = "Allow_Outbound_RdpSsh"
        priority              = 700
        protocol              = "*"
        source_address_prefix = "*"
        source_port_range     = "*"

      },
      {
        access                     = "Allow"
        description                = "Allow_Outbound_AzureCloud"
        destination_address_prefix = "AzureCloud"
        destination_port_range     = "443"
        direction                  = "Outbound"
        name                       = "Allow_Outbound_AzureCloud"
        priority                   = 800
        protocol                   = "Tcp"
        source_address_prefix      = "*"
        source_port_range          = "*"

      },
      {
        access                     = "Allow"
        description                = "Allow_Outbound_BastionHost"
        destination_address_prefix = "VirtualNetwork"
        destination_port_ranges = [
          "8080",
          "5701"
        ]
        direction             = "Outbound"
        name                  = "Allow_Outbound_BastionHost"
        priority              = 900
        protocol              = "Tcp"
        source_address_prefix = "VirtualNetwork"
        source_port_range     = "*"
      },
      {
        access                     = "Allow"
        description                = "Allow_Outbound_SessionInformation"
        destination_address_prefix = "Internet"
        destination_port_range     = "80"
        direction                  = "Outbound"
        name                       = "Allow_Outbound_SessionInformation"
        priority                   = 1000
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
      },
      {
        access                     = "Deny"
        description                = ""
        destination_address_prefix = "*"
        destination_port_range     = "*"
        direction                  = "Outbound"
        name                       = "Deny_Outbound_All"
        priority                   = 4096
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
      }
    ]
  },
  {
    name       = "nsg-snet-pep"
    subnetname = "snet-pep"
    security_rule = [
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "*"
        destination_port_range     = "10050"
        direction                  = "Inbound"
        name                       = "Allow_Inbound_Monitor"
        priority                   = 500
        protocol                   = "*"
        source_address_prefix      = "10.0.7.11/32"
        source_port_range          = "*"
      },
      {
        access                     = "Deny"
        description                = ""
        destination_address_prefix = "*"
        destination_port_range     = "*"
        direction                  = "Inbound"
        name                       = "Deny_Inbound_All"
        priority                   = 4096
        protocol                   = "*"
        source_address_prefix      = "10.0.7.11/32"
        source_port_range          = "*"
      },
      {
        access                     = "Deny"
        description                = ""
        destination_address_prefix = "*"
        destination_port_range     = "*"
        direction                  = "Outbound"
        name                       = "Deny_Outbound_All"
        priority                   = 4096
        protocol                   = "*"
        source_address_prefix      = "*"
        source_port_range          = "*"
      }
    ]
  },
  {
    name       = "nsg-snet-dbw-private"
    subnetname = "snet-dbw-private"
    security_rule = [
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "VirtualNetwork"
        destination_port_range     = "*"
        direction                  = "Inbound"
        name                       = "nsgsr-allow-dbw-vnet-inbound"
        priority                   = 200
        protocol                   = "*"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "VirtualNetwork"
        destination_port_range     = "*"
        direction                  = "Outbound"
        name                       = "nsgsr-allow-dbw-vnet-outbound"
        priority                   = 210
        protocol                   = "*"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "Sql"
        destination_port_ranges = [
          "3306"
        ]
        direction             = "Outbound"
        name                  = "nsgsr-allow-dbw-sql-outbound"
        priority              = 220
        protocol              = "Tcp"
        source_address_prefix = "VirtualNetwork"
        source_port_range     = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "Storage"
        destination_port_range     = "443"
        direction                  = "Outbound"
        name                       = "nsgsr-allow-dbw-st-outbound"
        priority                   = 230
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "EventHub"
        destination_port_range     = "9093"
        direction                  = "Outbound"
        name                       = "nsgsr-allow-dbw-eventhub-outbound"
        priority                   = 240
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "AzureDatabricks"
        destination_port_range     = "443"
        direction                  = "Outbound"
        name                       = "nsgsr-allow-dbw-dbw-outbound"
        priority                   = 250
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      }
    ]
  },
  {
    name       = "nsg-snet-dbw-public"
    subnetname = "snet-dbw-public"
    security_rule = [
       {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "VirtualNetwork"
        destination_port_range     = "*"
        direction                  = "Inbound"
        name                       = "nsgsr-allow-dbw-vnet-inbound"
        priority                   = 200
        protocol                   = "*"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "VirtualNetwork"
        destination_port_range     = "*"
        direction                  = "Outbound"
        name                       = "nsgsr-allow-dbw-vnet-outbound"
        priority                   = 210
        protocol                   = "*"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "Sql"
        destination_port_ranges = [
        "3306"]
        direction             = "Outbound"
        name                  = "nsgsr-allow-dbw-sql-outbound"
        priority              = 220
        protocol              = "Tcp"
        source_address_prefix = "VirtualNetwork"
        source_port_range     = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "Storage"
        destination_port_range     = "443"
        direction                  = "Outbound"
        name                       = "nsgsr-allow-dbw-st-outbound"
        priority                   = 230
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "EventHub"
        destination_port_range     = "9093"
        direction                  = "Outbound"
        name                       = "nsgsr-allow-dbw-eventhub-outbound"
        priority                   = 240
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = "AzureDatabricks"
        destination_port_range     = "443"
        direction                  = "Outbound"
        name                       = "nsgsr-allow-dbw-dbw-outbound"
        priority                   = 250
        protocol                   = "Tcp"
        source_address_prefix      = "VirtualNetwork"
        source_port_range          = "*"
      }
    ]
  }
]
