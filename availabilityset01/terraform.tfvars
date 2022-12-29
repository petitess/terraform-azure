availabilitysets = {
    "01" = {
        name = "vmdctest01"
    }
    "02" = {
        name = "vmapptest01"
    }
}

vmavail = {  
  "vmdctest01" = {
    name = "vmdctest01"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = true
    rgname = "rg-vmdctest01"
    availname = "avail-vmdctest01"
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface = {
      subnetname = "snet-core-test-01"
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
  "vmdctest02" = {
    name = "vmdctest02"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = true
    rgname = "rg-vmdctest01"
    availname = "avail-vmdctest01"
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupB"
    }
    network_interface = {
      subnetname = "snet-core-test-01"
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
  }
  "vmapptest01" = {
    name = "vmapptest01"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = true
    rgname = "rg-vmapptest01"
    availname = "avail-vmapptest01"
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface = {
      subnetname = "snet-app-test-01"
      primary = "true"
      private_ip_address = "10.0.7.11"
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
      deploydisk01 = false
      disk_size_gb = 10
    }
  }
  "vmapptest02" = {
    name = "vmapptest02"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = true
    rgname = "rg-vmapptest01"
    availname = "avail-vmapptest01"
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupB"
    }
    network_interface = {
      subnetname = "snet-app-test-01"
      primary = "true"
      private_ip_address = "10.0.7.12"
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
      deploydisk01 = false
      disk_size_gb = 10
    }
  }
  }