prefix   = "infra-test"
env      = "test"
location = "swedencentral"
tags = {
  Environment = "Test"
  Application = "Infra"
}
vnet = {
  name          = "vnet-infra-test01"
  address_space = ["10.10.0.0/16"]
}
natgatewaysubnets = [
  #"snet-web-test-01"
]
availabilitysets = {
  "01" = {
    name = "vmadctest01"
  }
}
subnets = [
  {
    name             = "GatewaySubnet"
    address_prefixes = ["10.10.0.0/24"]
  },
  {
    name             = "AzureFirewallSubnet"
    address_prefixes = ["10.10.1.0/24"]
  },
  {
    name             = "AzureBastionSubnet"
    address_prefixes = ["10.10.2.0/24"]
  },
  {
    name             = "snet-pe-test-01"
    address_prefixes = ["10.10.3.0/24"]
  },
  {
    name             = "snet-core-test-01"
    address_prefixes = ["10.10.4.0/24"]
  },
  {
    name             = "snet-mgmt-test-01"
    address_prefixes = ["10.10.5.0/24"]
  },
  {
    name             = "snet-sql-test-01"
    address_prefixes = ["10.10.6.0/24"]
  },
  {
    name             = "snet-app-test-01"
    address_prefixes = ["10.10.7.0/24"]
  },
  {
    name             = "snet-web-test-01"
    address_prefixes = ["10.10.8.0/24"]
  },
  {
    name             = "snet-ctx-test-01"
    address_prefixes = ["10.10.9.0/24"]
  },
  {
    name             = "snet-vda-test-01"
    address_prefixes = ["10.10.10.0/24"]
  }
]

nsg = [
  {
    name       = "nsg-AzureBastion"
    subnetname = "AzureBastionSubnet"
    security_rule = [
      {
        access                                     = "Allow"
        description                                = "Allow Monitor"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10050"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Inbound_Https"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "443"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Https"
        priority                                   = 600
        protocol                                   = "Tcp"
        source_address_prefix                      = "Internet"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Inbound_GatewayManager"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "443"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_GatewayManager"
        priority                                   = 700
        protocol                                   = "Tcp"
        source_address_prefix                      = "GatewayManager"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Inbound_AzureLoadBalancer"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "443"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_AzureLoadBalancer"
        priority                                   = 800
        protocol                                   = "Tcp"
        source_address_prefix                      = "AzureLoadBalancer"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Inbound_BastionHost"
        destination_address_prefix                 = "VirtualNetwork"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "8080",
          "5701"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_BastionHost"
        priority                              = 900
        protocol                              = "*"
        source_address_prefix                 = "VirtualNetwork"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Deny"
        description                                = "Deny_Inbound_All"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Deny_Inbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Outbound_RdpSsh"
        destination_address_prefix                 = "VirtualNetwork"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "22",
          "3389"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_RdpSsh"
        priority                              = 700
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Outbound_AzureCloud"
        destination_address_prefix                 = "AzureCloud"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "443"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_AzureCloud"
        priority                                   = 800
        protocol                                   = "Tcp"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Outbound_BastionHost"
        destination_address_prefix                 = "VirtualNetwork"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "8080",
          "5701"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_BastionHost"
        priority                              = 900
        protocol                              = "Tcp"
        source_address_prefix                 = "VirtualNetwork"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Outbound_SessionInformation"
        destination_address_prefix                 = "Internet"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "80"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_SessionInformation"
        priority                                   = 1000
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Deny_Outbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      }
    ]
  },
  {
    name       = "nsg-snet-pe-test-01"
    subnetname = "snet-pe-test-01"
    security_rule = [
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10050"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Deny_Inbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Deny_Outbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      }
    ]
  },
  {
    name       = "nsg-snet-core-test-01"
    subnetname = "snet-core-test-01"
    security_rule = [
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "22",
          "3389"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Bastion"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "10.10.2.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_ICMP"
        priority                                   = 200
        protocol                                   = "Icmp"
        source_address_prefix                      = "10.10.5.0/24"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Mgmt"
        priority                              = 300
        protocol                              = "*"
        source_address_prefix                 = "10.10.5.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction             = "Inbound"
        name                  = "Allow_Inbound_ActiveDirectory"
        priority              = 400
        protocol              = "*"
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
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10050"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Inbound_AzureLoadBalancer"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_AzureLoadBalancer"
        priority                                   = 600
        protocol                                   = "Tcp"
        source_address_prefix                      = "AzureLoadBalancer"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Deny_Inbound_All"
        priority                                   = 4000
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction             = "Outbound"
        name                  = "Allow_Outbound_ActiveDirectory"
        priority              = 400
        protocol              = "*"
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
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.7.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10051"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "Internet"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Internet"
        priority                                   = 4000
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Deny_Outbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      }
    ]
  },
  {
    name       = "nsg-snet-mgmt-test-01"
    subnetname = "snet-mgmt-test-01"
    security_rule = [
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "22",
          "3389"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Bastion"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "10.10.2.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_ICMP"
        priority                                   = 200
        protocol                                   = "Icmp"
        source_address_prefix                      = "10.10.5.0/24"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Mgmt"
        priority                              = 300
        protocol                              = "*"
        source_address_prefix                 = "10.10.5.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_ActiveDirectory"
        priority                              = 400
        protocol                              = "*"
        source_address_prefix                 = "10.10.4.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10050"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "445"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Files"
        priority                                   = 600
        protocol                                   = "*"
        source_address_prefix                      = "10.10.0.0/16"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.5.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "443",
          "445",
          "6910-6969",
          "49152-65535"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_CTX_VDA"
        priority                              = 700
        protocol                              = "*"
        source_address_prefix                 = "10.10.9.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Inbound_AzureLoadBalancer"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_AzureLoadBalancer"
        priority                                   = 800
        protocol                                   = "Tcp"
        source_address_prefix                      = "AzureLoadBalancer"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = ""
        destination_address_prefixes = [
          "10.10.5.200",
          "10.10.5.201"
        ]
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "443",
          "445",
          "6910-6969",
          "49152-65535"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_CTX_ADC"
        priority                              = 900
        protocol                              = "*"
        source_address_prefix                 = "10.10.0.0/16"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Deny_Inbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.0.0/16"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_ICMP"
        priority                                   = 100
        protocol                                   = "Icmp"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.0.0/16"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_Mgmt"
        priority                              = 200
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.4.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_ActiveDirectory"
        priority                              = 300
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.7.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10051"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Monitor"
        priority                                   = 400
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.9.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "443",
          "445",
          "6910-6969",
          "49152-65535"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_CTX_services"
        priority                              = 500
        protocol                              = "*"
        source_address_prefix                 = "10.10.5.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "443",
          "3003",
          "3008",
          "3009"
        ]
        direction             = "Outbound"
        name                  = "Allow_Outbound_CTX_ADC"
        priority              = 600
        protocol              = "*"
        source_address_prefix = ""
        source_address_prefixes = [
          "10.10.5.200",
          "10.10.5.201"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "Internet"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Internet"
        priority                                   = 4000
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Deny_Outbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      }
    ]
  },
  {
    name       = "nsg-snet-sql-test-01"
    subnetname = "snet-sql-test-01"
    security_rule = [
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "22",
          "3389"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Bastion"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "10.10.2.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_ICMP"
        priority                                   = 200
        protocol                                   = "Icmp"
        source_address_prefix                      = "10.10.5.0/24"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Mgmt"
        priority                              = 300
        protocol                              = "*"
        source_address_prefix                 = "10.10.5.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_ActiveDirectory"
        priority                              = 400
        protocol                              = "*"
        source_address_prefix                 = "10.10.4.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10050"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "1433"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_SQL"
        priority                                   = 600
        protocol                                   = "*"
        source_address_prefix                      = ""
        source_address_prefixes = [
          "10.10.7.0/24",
          "10.10.8.0/24"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.6.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "1433",
          "1434"
        ]
        direction             = "Inbound"
        name                  = "Allow_Inbound_SQL_CTX"
        priority              = 700
        protocol              = "*"
        source_address_prefix = ""
        source_address_prefixes = [
          "10.10.9.0/24",
          "10.10.10.0/24"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "80"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_SQL_SSRS"
        priority                                   = 800
        protocol                                   = "*"
        source_address_prefix                      = "10.10.8.0/24"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Deny_Inbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.4.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_ActiveDirectory"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.7.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10051"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Monitor"
        priority                                   = 200
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.5.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "445"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_File"
        priority                                   = 300
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "Internet"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Internet"
        priority                                   = 4000
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Deny_Outbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      }
    ]
  },
  {
    name       = "nsg-snet-app-test-01"
    subnetname = "snet-app-test-01"
    security_rule = [
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "22",
          "3389"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Bastion"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "10.10.2.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_ICMP"
        priority                                   = 200
        protocol                                   = "Icmp"
        source_address_prefix                      = "10.10.5.0/24"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Mgmt"
        priority                              = 300
        protocol                              = "*"
        source_address_prefix                 = "10.10.5.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_ActiveDirectory"
        priority                              = 400
        protocol                              = "*"
        source_address_prefix                 = "10.10.4.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10050"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.7.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10051"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Zabbix"
        priority                                   = 600
        protocol                                   = "*"
        source_address_prefix                      = "10.10.0.0/16"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Deny_Inbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.4.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_ActiveDirectory"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.7.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10051"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Monitor"
        priority                                   = 200
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.0.0/16"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10051"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Zabbix"
        priority                                   = 300
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.6.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "1433"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_SQL"
        priority                                   = 400
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "Internet"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Internet"
        priority                                   = 4000
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Deny_Outbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      }
    ]
  },
  {
    name       = "nsg-snet-web-test-01"
    subnetname = "snet-web-test-01"
    security_rule = [
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "22",
          "3389"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Bastion"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "10.10.2.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_ICMP"
        priority                                   = 200
        protocol                                   = "Icmp"
        source_address_prefix                      = "10.10.5.0/24"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Mgmt"
        priority                              = 300
        protocol                              = "*"
        source_address_prefix                 = "10.10.5.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_ActiveDirectory"
        priority                              = 400
        protocol                              = "*"
        source_address_prefix                 = "10.10.4.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10050"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "443"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Web"
        priority                                   = 600
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = "WEBBTIDBOK"
        destination_address_prefix                 = "10.10.8.16/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "443",
          "8080",
          "8082"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Web_WTB"
        priority                              = 700
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.8.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "8080",
          "8082"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_WTB"
        priority                              = 800
        protocol                              = "*"
        source_address_prefix                 = "10.10.8.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Inbound_AzureLoadBalancer"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_AzureLoadBalancer"
        priority                                   = 900
        protocol                                   = "Tcp"
        source_address_prefix                      = "AzureLoadBalancer"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = "Netscaler floating IP"
        destination_address_prefix                 = "Internet"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "443"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Web_ADC_CSR"
        priority                              = 1000
        protocol                              = "*"
        source_address_prefix                 = "Internet"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Deny_Inbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.4.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_ActiveDirectory"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.7.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10051"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Monitor"
        priority                                   = 200
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.6.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "1433"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_SQL"
        priority                                   = 300
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.5.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "445"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_File"
        priority                                   = 400
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.6.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "80"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_SQL_SSRS"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.8.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "443",
          "8080",
          "8082"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_WTB"
        priority                              = 600
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "443",
          "3003",
          "3008",
          "3009"
        ]
        direction             = "Outbound"
        name                  = "Allow_Outbound_ADC"
        priority              = 700
        protocol              = "*"
        source_address_prefix = ""
        source_address_prefixes = [
          "10.10.8.8",
          "10.10.8.9"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "Internet"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Internet"
        priority                                   = 4000
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Deny_Outbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      }
    ]
  },
  {
    name       = "nsg-snet-ctx-test-01"
    subnetname = "snet-ctx-test-01"
    security_rule = [
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "22",
          "3389"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Bastion"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "10.10.2.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_ICMP"
        priority                                   = 200
        protocol                                   = "Icmp"
        source_address_prefix                      = "10.10.5.0/24"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Mgmt"
        priority                              = 300
        protocol                              = "*"
        source_address_prefix                 = "10.10.5.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_ActiveDirectory"
        priority                              = 400
        protocol                              = "*"
        source_address_prefix                 = "10.10.4.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10050"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.9.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "67",
          "69",
          "80",
          "443",
          "445",
          "808",
          "1494",
          "2071",
          "2598",
          "4011",
          "7279",
          "8082-8083",
          "27000",
          "54321",
          "54322",
          "54323",
          "6890-6969"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_CTX_Services"
        priority                              = 600
        protocol                              = "*"
        source_address_prefix                 = "10.10.9.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.9.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "443",
          "445",
          "6910-6969",
          "49152-65535"
        ]
        direction             = "Inbound"
        name                  = "Allow_Inbound_CTX_VDA"
        priority              = 700
        protocol              = "*"
        source_address_prefix = ""
        source_address_prefixes = [
          "10.10.10.0/24",
          "10.10.5.0/24"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = ""
        destination_address_prefixes = [
          "10.10.9.13/32",
          "10.10.9.14/32"
        ]
        destination_application_security_group_ids = []
        destination_port_range                     = "443"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_StoreFront"
        priority                                   = 800
        protocol                                   = "*"
        source_address_prefix                      = ""
        source_address_prefixes = [
          "10.10.8.8/32",
          "10.10.8.9/32"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Inbound_AzureLoadBalancer"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_AzureLoadBalancer"
        priority                                   = 900
        protocol                                   = "*"
        source_address_prefix                      = "AzureLoadBalancer"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = ""
        destination_address_prefixes = [
          "10.10.9.17/32",
          "10.10.9.18/32"
        ]
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "139",
          "443",
          "445",
          "7750",
          "7751"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_CPM"
        priority                              = 1000
        protocol                              = "*"
        source_address_prefix                 = "10.10.10.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Deny_Inbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.4.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_ActiveDirectory"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.7.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10051"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Monitor"
        priority                                   = 200
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.5.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "445"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_File"
        priority                                   = 300
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.9.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "67",
          "69",
          "80",
          "443",
          "445",
          "808",
          "1494",
          "2071",
          "2598",
          "4011",
          "7279",
          "8082-8083",
          "27000",
          "54321",
          "54322",
          "54323",
          "6890-6969"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_CTX_services"
        priority                              = 400
        protocol                              = "*"
        source_address_prefix                 = "10.10.9.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.6.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "1433",
          "1434"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_SQL_PVS"
        priority                              = 500
        protocol                              = "*"
        source_address_prefix                 = "10.10.9.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = ""
        destination_address_prefixes = [
          "10.10.10.0/24",
          "10.10.5.0/24"
        ]
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "443",
          "8080",
          "8082"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_CTX_VDA"
        priority                              = 600
        protocol                              = "*"
        source_address_prefix                 = "10.10.9.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.6.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "1433"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_CPM_SQL"
        priority                                   = 700
        protocol                                   = "*"
        source_address_prefix                      = ""
        source_address_prefixes = [
          "10.10.9.17/32",
          "10.10.9.18/32"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.10.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "139",
          "443",
          "445",
          "7750",
          "7751",
          "7771"
        ]
        direction             = "Outbound"
        name                  = "Allow_Outbound_CPM_VDA"
        priority              = 800
        protocol              = "*"
        source_address_prefix = ""
        source_address_prefixes = [
          "10.10.9.17/32",
          "10.10.9.18/32"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },

      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "Internet"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Internet"
        priority                                   = 4000
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Deny_Outbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      }
    ]
  },
  {
    name       = "nsg-snet-vda-test-01"
    subnetname = "snet-vda-test-01"
    security_rule = [
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "22",
          "3389"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Bastion"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "10.10.2.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_ICMP"
        priority                                   = 200
        protocol                                   = "Icmp"
        source_address_prefix                      = "10.10.5.0/24"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
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
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_Mgmt"
        priority                              = 300
        protocol                              = "*"
        source_address_prefix                 = "10.10.5.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_ActiveDirectory"
        priority                              = 400
        protocol                              = "*"
        source_address_prefix                 = "10.10.4.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10050"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Monitor"
        priority                                   = 500
        protocol                                   = "*"
        source_address_prefix                      = "10.10.7.11/32"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.10.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "443",
          "445",
          "1494",
          "2598",
          "2071",
          "6901",
          "6902",
          "6905",
          "6910-6969",
          "49152-65535"
        ]
        direction             = "Inbound"
        name                  = "Allow_Inbound_CTX_VDA"
        priority              = 600
        protocol              = "*"
        source_address_prefix = ""
        source_address_prefixes = [
          "10.10.9.0/24",
          "10.10.10.0/24"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = ""
        destination_address_prefixes = [
          "10.10.10.200",
          "10.10.10.201"
        ]
        destination_application_security_group_ids = []
        destination_port_range                     = "443"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_Web_ADC"
        priority                                   = 700
        protocol                                   = "*"
        source_address_prefix                      = "10.10.0.0/16"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.10.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "139",
          "443",
          "445",
          "7750",
          "7751",
          "7771"
        ]
        direction                             = "Inbound"
        name                                  = "Allow_Inbound_CPM_MGMT"
        priority                              = 800
        protocol                              = "*"
        source_address_prefix                 = "10.10.9.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = "Allow_Inbound_AzureLoadBalancer"
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Allow_Inbound_AzureLoadBalancer"
        priority                                   = 900
        protocol                                   = "*"
        source_address_prefix                      = "AzureLoadBalancer"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Inbound"
        name                                       = "Deny_Inbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.4.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "53",
          "88",
          "123",
          "135",
          "137-139",
          "389",
          "445",
          "464",
          "636",
          "3268-3269",
          "3389",
          "5722",
          "9389",
          "49152-65535"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_ActiveDirectory"
        priority                              = 100
        protocol                              = "*"
        source_address_prefix                 = "*"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.7.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "10051"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Monitor"
        priority                                   = 200
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.5.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "445"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_File"
        priority                                   = 300
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.9.0/24"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "443",
          "445",
          "6910-6969",
          "49152-65535"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_CTX_services"
        priority                              = 400
        protocol                              = "*"
        source_address_prefix                 = "10.10.10.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "10.10.6.11/32"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "1433",
          "1434"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_CTX_SQL"
        priority                              = 500
        protocol                              = "*"
        source_address_prefix                 = "10.10.10.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "443",
          "3003",
          "3008",
          "3009"
        ]
        direction             = "Outbound"
        name                  = "Allow_Outbound_CTX_ADC"
        priority              = 600
        protocol              = "*"
        source_address_prefix = ""
        source_address_prefixes = [
          "10.10.10.200",
          "10.10.10.201"
        ]
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = ""
        destination_address_prefixes = [
          "10.10.9.17/32",
          "10.10.9.18/32"
        ]
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "135",
          "139",
          "443",
          "445",
          "7750",
          "7751"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_CPM"
        priority                              = 700
        protocol                              = "*"
        source_address_prefix                 = "10.10.10.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                     = "Allow"
        description                = ""
        destination_address_prefix = ""
        destination_address_prefixes = [
          "10.10.10.0/24",
          "10.10.9.0/24"
        ]
        destination_application_security_group_ids = []
        destination_port_range                     = ""
        destination_port_ranges = [
          "80",
          "443",
          "1494",
          "2598",
          "6901",
          "6902",
          "6905",
          "16500-16509",
          "54321-54323"
        ]
        direction                             = "Outbound"
        name                                  = "Allow_Outbound_CTX_VDA"
        priority                              = 800
        protocol                              = "*"
        source_address_prefix                 = "10.10.10.0/24"
        source_address_prefixes               = []
        source_application_security_group_ids = []
        source_port_range                     = "*"
        source_port_ranges                    = []
      },
      {
        access                                     = "Allow"
        description                                = ""
        destination_address_prefix                 = "Internet"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Allow_Outbound_Internet"
        priority                                   = 4000
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      },
      {
        access                                     = "Deny"
        description                                = ""
        destination_address_prefix                 = "*"
        destination_address_prefixes               = []
        destination_application_security_group_ids = []
        destination_port_range                     = "*"
        destination_port_ranges                    = []
        direction                                  = "Outbound"
        name                                       = "Deny_Outbound_All"
        priority                                   = 4096
        protocol                                   = "*"
        source_address_prefix                      = "*"
        source_address_prefixes                    = []
        source_application_security_group_ids      = []
        source_port_range                          = "*"
        source_port_ranges                         = []
      }
    ]
  }
]
vms = {
  "01" = {
    name                     = "vmadctest01"
    size                     = "Standard_DS3_v2"
    rgname                   = "rg-vmadctest01"
    availname                = "avail-vmadctest01"
    os_disk_size_gb          = 64
    AzureMonitorWindowsAgent = false
    tags = {
      Application      = "Citrix"
      Service          = "ADC"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface = [
      {
        name                          = "nic1"
        publicip                      = false
        subnetname                    = "snet-mgmt-test-01"
        primary                       = "true"
        private_ip_address            = "10.10.5.200"
        private_ip_address_allocation = "Static"
        accelerated_networking        = false
        externalLB                    = false
        internalLB                    = false
      },
      {
        name                          = "nic2"
        publicip                      = false
        subnetname                    = "snet-vda-test-01"
        primary                       = "true"
        private_ip_address            = "10.10.10.200"
        private_ip_address_allocation = "Static"
        accelerated_networking        = true
        externalLB                    = false
        internalLB                    = true
      },
      {
        name                          = "nic3"
        publicip                      = false
        subnetname                    = "snet-web-test-01"
        primary                       = "true"
        private_ip_address            = "10.10.8.8"
        private_ip_address_allocation = "Static"
        accelerated_networking        = true
        externalLB                    = true
        internalLB                    = false
      }
    ]
    image_reference = {
      publisher = "citrix"
      offer     = "netscalervpx-131"
      sku       = "netscalerbyol"
      versionx  = "latest"
    }
    plan = {
      name      = "netscalerbyol"
      publisher = "citrix"
      product   = "netscalervpx-131"
    }
    datadisks = []
  }
  "02" = {
    name                     = "vmadctest02"
    size                     = "Standard_DS3_v2"
    rgname                   = "rg-vmadctest01"
    availname                = "avail-vmadctest01"
    os_disk_size_gb          = 64
    AzureMonitorWindowsAgent = false
    tags = {
      Application      = "Citrix"
      Service          = "ADC"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface = [
      {
        name                          = "nic1"
        publicip                      = false
        subnetname                    = "snet-mgmt-test-01"
        primary                       = "true"
        private_ip_address            = "10.10.5.201"
        private_ip_address_allocation = "Static"
        accelerated_networking        = false
        externalLB                    = false
        internalLB                    = false
      },
      {
        name                          = "nic2"
        publicip                      = false
        subnetname                    = "snet-vda-test-01"
        primary                       = "true"
        private_ip_address            = "10.10.10.201"
        private_ip_address_allocation = "Static"
        accelerated_networking        = true
        externalLB                    = false
        internalLB                    = true
      },
      {
        name                          = "nic3"
        publicip                      = false
        subnetname                    = "snet-web-test-01"
        primary                       = "true"
        private_ip_address            = "10.10.8.9"
        private_ip_address_allocation = "Static"
        accelerated_networking        = true
        externalLB                    = true
        internalLB                    = false
      }
    ]
    image_reference = {
      publisher = "citrix"
      offer     = "netscalervpx-131"
      sku       = "netscalerbyol"
      versionx  = "latest"
    }
    plan = {
      name      = "netscalerbyol"
      publisher = "citrix"
      product   = "netscalervpx-131"
    }
    datadisks = []
  }
}
