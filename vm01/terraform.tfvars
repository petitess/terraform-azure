vnet = {
  name = "vnet-infra-test01"
  address_space = [ "10.0.0.0/16" ]
}

natgatewaysubnets = [
  #"snet-web-test-01"
]
subnets = [
  {
    name = "GatewaySubnet"
    address_prefixes = [ "10.0.0.0/24" ]
  },
  {
    name = "AzureFirewallSubnet"
    address_prefixes = [ "10.0.1.0/24" ]
  },
  {
    name = "AzureBastionSubnet"
    address_prefixes = [ "10.0.2.0/24" ]
  },
  {
    name = "snet-pe-test-01"
    address_prefixes = [ "10.0.3.0/24" ]
  },
  {
    name = "snet-core-test-01"
    address_prefixes = [ "10.0.4.0/24" ]
  },
  {
    name = "snet-mgmt-test-01"
    address_prefixes = [ "10.0.5.0/24" ]
  },
  {
    name = "snet-sql-test-01"
    address_prefixes = [ "10.0.6.0/24" ]
  },
  {
    name ="snet-app-test-01"
    address_prefixes = [ "10.0.7.0/24" ]
  },
  {
    name ="snet-web-test-01"
    address_prefixes = [ "10.0.8.0/24" ]
  }
]

vms = {  
  "vmdctest01" = {
    name = "vmdctest01"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = true
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface =  [
      {
        name = "nic1"
        publicip = false
        subnetname = "snet-core-test-01"
        primary = "true"
        private_ip_address = "10.0.4.11"
        private_ip_address_allocation = "Static"
      }
    ]
    image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      versionx   = "latest"
    }
    datadisks = [
     {
      name = "datadisk01"
      disk_size_gb = 10
      lun = 1
    }
    ]
  }
  "vmwebtest01" = {
    name = "vmwebtest01"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = true
    tags = {
      Application = "app"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface =  [
      {
        name = "nic1"
        publicip = false
        subnetname = "snet-web-test-01"
        primary = "true"
        private_ip_address = "10.0.8.15"
        private_ip_address_allocation = "Static"
      }
    ]
    image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      versionx   = "latest"
    }
    datadisks = []
  }
}
