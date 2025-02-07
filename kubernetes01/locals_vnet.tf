locals {
  location = "swedencentral"
  prefix   = "hub-${var.env}"
  tags = {
    Environment = var.env
    Application = "hub"
  }
  vnet_name          = "vnet-${local.prefix}01"
  vnet_address_space = ["10.1.0.0/16"]

  natgatewaysubnets = [
    #"snet-pep"
  ]

  subnets = [
    {
      name             = "GatewaySubnet"
      address_prefixes = [cidrsubnet(local.vnet_address_space[0], 9, 0)]
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name             = "AzureFirewallSubnet"
      address_prefixes = [cidrsubnet(local.vnet_address_space[0], 9, 1)]
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name             = "AzureBastionSubnet"
      address_prefixes = [cidrsubnet(local.vnet_address_space[0], 9, 2)]
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name             = "snet-pep"
      address_prefixes = [cidrsubnet(local.vnet_address_space[0], 8, 3)]
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name             = "snet-aks"
      address_prefixes = [cidrsubnet(local.vnet_address_space[0], 8, 4)]
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name              = "snet-aks-aci"
      address_prefixes  = [cidrsubnet(local.vnet_address_space[0], 8, 5)]
      delegations       = ["Microsoft.ContainerInstance/containerGroups"]
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name              = "snet-aks-agic"
      address_prefixes  = [cidrsubnet(local.vnet_address_space[0], 4, 6)]
      service_endpoints = ["Microsoft.Storage"]
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
    },
    {
      name          = "nsg-snet-aks"
      subnetname    = "snet-aks"
      security_rule = []
    },
    {
      name          = "nsg-snet-aks-aci"
      subnetname    = "snet-aks-aci"
      security_rule = []
    }
  ]
}
