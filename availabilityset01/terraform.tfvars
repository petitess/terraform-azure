availabilitysets = {
    "vmdctest01" = {
        name = "vmdctest01"
    }
    "vmapptest01" = {
        name = "vmapptest01"
    }
}

vmsnetcore = {  
  "vmdctest01" = {
    name = "vmdctest01"
    rgname = "rg-vmdctest01"
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
    availname = "avail-vmdctest01"
  }
  "vmdctest02" = {
    name = "vmdctest02"
    rgname = "rg-vmdctest01"
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
      private_ip_address = "10.0.4.12"
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
    availname = "avail-vmdctest01"
  }
  "vmapptest01" = {
    name = "vmapptest01"
    rgname = "rg-vmapptest01"
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
      private_ip_address = "10.0.4.15"
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
    availname = "avail-vmapptest01"
  }
  "vmapptest02" = {
    name = "vmapptest02"
    rgname = "rg-vmapptest01"
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
      private_ip_address = "10.0.4.16"
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
    availname = "avail-vmapptest01"
  }
}