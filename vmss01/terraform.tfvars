
vmss = {  
  "vmsstest01" = {
    name = "vmssapp01"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = false
    instances = 2
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface = {
      subnet_name = "snet-core-test-01"
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
  }
  "vmsstest02" = {
    name = "vmssapp02"
    size = "Standard_B2s"
    os_disk_size_gb = 127
    AzureMonitorWindowsAgent = false
    instances = 2
    tags = {
      Application = "infra"
      Service = "core"
      UpdateManagement = "Critical_Monthly_GroupA"
    }
    network_interface = {
      subnet_name = "snet-core-test-01"
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
  }
}
