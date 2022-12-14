
vmsnetcore = {  
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
    network_interface = {
      primary = "true"
      private_ip_address = "10.0.4.11"
      private_ip_address_allocation = "Static"
      publicip = false
    }
    image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      versionx   = "latest"
    }
    datadisk01 = {
      deploydisk01 = true
      disk_size_gb = 10
    }
  }
}
vmsnetapp = {  
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
    network_interface = {
      primary = "true"
      private_ip_address = "10.0.7.15"
      private_ip_address_allocation = "Static"
      publicip = false
    }
    image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      versionx   = "latest"
    }
    datadisk01 = {
      deploydisk01 = true
      disk_size_gb = 10
    }
  }
  "vmwebtest02" = {
    name = "vmwebtest02"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = true
    tags = {
      Application = "app"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface = {
      primary = "true"
      private_ip_address = "10.0.7.16"
      private_ip_address_allocation = "Static"
      publicip = false
    }
    image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      versionx   = "latest"
    }
    datadisk01 = {
      deploydisk01 = true
      disk_size_gb = 10
    }
  }
}
vmsnetmgmt = {  
  "vmmgmttest01" = {
    name = "vmmgmttest01"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = true
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface = {
      primary = "true"
      private_ip_address = "10.0.5.11"
      private_ip_address_allocation = "Static"
      publicip = false
    }
    image_reference = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      versionx   = "latest"
    }
    datadisk01 = {
      deploydisk01 = true
      disk_size_gb = 10
    }
  }
}

