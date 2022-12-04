vms-snetapp = {  
    "vmweb01" = {
    name = "vmweb01"
    size = "Standard_B2s"
    osdisksize = 127
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    image = {
      offer = "WindowsServer"
      publisher = "MicrosoftWindowsServer"
      sku = "2022-Datacenter"
      version = "latest"
    }
    networkInterfaces = {
      private_ip_address = "10.0.7.19"
    }
  }
  "vmapp01" = {
    name = "vmapp01"
    size = "Standard_B2s"
    osdisksize = 127
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    image = {
      offer = "WindowsServer"
      publisher = "MicrosoftWindowsServer"
      sku = "2022-Datacenter"
      version = "latest"
    }
    networkInterfaces = {
      private_ip_address = "10.0.7.29"
    }
  }
  }

  vms-snetcore = {  
    "vmdctest01" = {
    name = "vmdctest01"
    size = "Standard_B2s"
    osdisksize = 127
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupB"
    }
    image = {
      offer = "WindowsServer"
      publisher = "MicrosoftWindowsServer"
      sku = "2022-Datacenter"
      version = "latest"
    }
    networkInterfaces = {
      private_ip_address = "10.0.4.15"
    }
  }
  }