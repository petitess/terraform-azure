locals {
  location = "swedencentral"
  prefix   = "hub-${var.env}"
  tags = {
    Environment = var.env
    Application = "hub"
  }
  st_name    = "stabcdefault01"
  st_rg_name = "rg-abc-default-01"

  my_ip              = "188.150.1.1"
  vnet_name          = "vnet-${local.prefix}01"
  vnet_address_space = ["10.1.0.0/16"]

  pdnsz = [
    "privatelink.database.windows.net",
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.azuredatabricks.net"
  ]

  natgatewaysubnets = [
    #"snet-pep"
  ]

  subnets = [
    {
      name             = "GatewaySubnet"
      address_prefixes = [cidrsubnet(local.vnet_address_space[0], 9, 0)]
    },
    {
      name             = "AzureFirewallSubnet"
      address_prefixes = [cidrsubnet(local.vnet_address_space[0], 9, 1)]
    },
    {
      name             = "AzureBastionSubnet"
      address_prefixes = [cidrsubnet(local.vnet_address_space[0], 9, 2)]
    },
    {
      name             = "snet-pep"
      address_prefixes = [cidrsubnet(local.vnet_address_space[0], 9, 3)]
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
    }
  ]
}

output "sub" {
  value = cidrsubnet(local.vnet_address_space[0], 9, 1)
}
