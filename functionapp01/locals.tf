locals {
  location    = "swedencentral"
  prefix      = "infra-${var.env}"
  prefixShort = "infra${var.env}"
  tags = {
    Environment = var.env
    Application = "Infra"
  }
  my_ip     = "188.150.1.1"
  vnet_name = "vnet-${local.prefix}01"
  vnet_address_space = {
    dev = ["10.1.0.0/16"]
    stg = ["10.2.0.0/16"]
  }

  natgatewaysubnets = [
    #"snet-pep"
  ]

  subnets = [
    {
      name             = "GatewaySubnet"
      address_prefixes = [cidrsubnet(local.vnet_address_space[var.env][0], 9, 0)]
    },
    {
      name             = "AzureFirewallSubnet"
      address_prefixes = [cidrsubnet(local.vnet_address_space[var.env][0], 9, 1)]
    },
    {
      name             = "AzureBastionSubnet"
      address_prefixes = [cidrsubnet(local.vnet_address_space[var.env][0], 9, 2)]
    },
    {
      name             = "snet-pep"
      address_prefixes = [cidrsubnet(local.vnet_address_space[var.env][0], 9, 3)]
    },
    {
      name             = "snet-func-outbound"
      address_prefixes = [cidrsubnet(local.vnet_address_space[var.env][0], 9, 4)]
      delegations = [
        "Microsoft.Web/serverFarms"
      ]
    },
    {
      name             = "snet-common"
      address_prefixes = [cidrsubnet(local.vnet_address_space[var.env][0], 9, 5)]
    }
  ]

  nsg = [
    {
      name       = "nsg-AzureBastion"
      subnetname = "AzureBastionSubnet"
      security_rule = [
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
          destination_address_prefix = "*"
          destination_port_ranges    = ["443", "445"]
          direction                  = "Inbound"
          name                       = "Allow_Inbound_Func"
          priority                   = 500
          protocol                   = "*"
          source_address_prefixes    = azurerm_subnet.subnets["snet-func-outbound"].address_prefixes
          source_port_range          = "*"
        },
        {
          access                     = "Deny"
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
          access                     = "Deny"
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
      name       = "nsg-snet-func-outbound"
      subnetname = "snet-func-outbound"
      security_rule = [
        {
          access                     = "Allow"
          destination_address_prefix = "VirtualNetwork"
          destination_port_range     = "*"
          direction                  = "Inbound"
          name                       = "nsgsr-allow-vnet-inbound"
          priority                   = 200
          protocol                   = "*"
          source_address_prefix      = "VirtualNetwork"
          source_port_range          = "*"
        }
      ]
    },
    {
      name       = "nsg-snet-common"
      subnetname = "snet-common"
      security_rule = [
        {
          access                     = "Allow"
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
          destination_address_prefix = "Sql"
          destination_port_ranges = [
          "3306"]
          direction             = "Outbound"
          name                  = "nsgsr-allow-dbw-sql-outbound"
          priority              = 220
          protocol              = "*"
          source_address_prefix = "VirtualNetwork"
          source_port_range     = "*"
        },
        {
          access                     = "Allow"
          destination_address_prefix = "Storage"
          destination_port_range     = "443"
          direction                  = "Outbound"
          name                       = "nsgsr-allow-dbw-st-outbound"
          priority                   = 230
          protocol                   = "*"
          source_address_prefix      = "VirtualNetwork"
          source_port_range          = "*"
        },
        {
          access                     = "Allow"
          destination_address_prefix = "EventHub"
          destination_port_range     = "9093"
          direction                  = "Outbound"
          name                       = "nsgsr-allow-dbw-eventhub-outbound"
          priority                   = 240
          protocol                   = "*"
          source_address_prefix      = "VirtualNetwork"
          source_port_range          = "*"
        }
      ]
    }
  ]
}