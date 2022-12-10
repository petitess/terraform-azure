provider "azurerm" {
    version         = "1.31"
}


resource "azurerm_resource_group" "example" {
  name     = "test"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "acceptanceTestVirtualNetwork1"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
}

resource "azurerm_subnet" "example" {
  name                 = "testsubnet"
  resource_group_name  = "${azurerm_resource_group.example.name}"
  virtual_network_name = "${azurerm_virtual_network.example.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "example" {
  count               = 2
  name                = "acceptanceTestNetworkInterface1"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.example.id}"
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
    ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = "${azurerm_subnet.example.id}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "storagea283r738fewc"
  resource_group_name      = "${azurerm_resource_group.example.name}"
  location                 = "${azurerm_resource_group.example.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_virtual_machine" "main" {
  count                 = 2
  name                  = "vm"
  location              = "${azurerm_resource_group.example.location}"
  resource_group_name   = "${azurerm_resource_group.example.name}"
  network_interface_ids = ["${element(azurerm_network_interface.example.*.id, count.index)}"]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2016SP1-WS2016"
    sku       = "Enterprise"
    version   = "latest"
  }
  storage_os_disk {
    name               = "osdisk"
    caching            = "ReadWrite"
    create_option      = "FromImage"
    managed_disk_type  = "Standard_LRS"
  }
  storage_data_disk {
    name               = "datadisk1"
    caching            = "None"
    create_option      = "Empty"
    disk_size_gb       = "1023"
    managed_disk_type  = "Standard_LRS"
    lun                = "0"
  }
    storage_data_disk {
    name               = "datadisk2"
    caching            = "None"
    create_option      = "Empty"
    disk_size_gb       = "1023"
    managed_disk_type  = "Standard_LRS"
    lun                = "1"
  }
  os_profile {
    computer_name  = "vm1"
    admin_username = "username"
    admin_password = "P@ssW00rd!"
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }
}

# resource "azurerm_virtual_machine_extension" "example" {
#   count                = "2"
#   name                 = "name"
#   location             = "${azurerm_resource_group.example.location}"
#   resource_group_name  = "${azurerm_resource_group.example.name}"
#   virtual_machine_name = "${element(azurerm_virtual_machine.main.*.name, count.index+1)}"
#   publisher            = "Microsoft.Powershell"
#   type                 = "DSC"
#   type_handler_version = "2.71"
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#       {
#           "modulesUrl": "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/301-sql-alwayson-md-ilb-zones/dsc/config-sqlao.ps1.zip",
#           "configurationFunction": "ConfigSQLAO.ps1\\ConfigSQLAO",
#           "properties": {
#               "domainName": "domain.com",
#               "clusterName": "cluster",
#               "vmNamePrefix": "vm",
#               "sqlAlwaysOnAvailabilityGroupName": "agname",
#               "sqlAlwaysOnAvailabilityGroupListenerName": "agListenerName",
#               "sqlAlwaysOnEndpointName": "agEpName",
#               "vmCount": 2
#               "clusterIpAddresses": "${local.ips_json1}",
#               "agListenerIpAddress": "10.0.0.5",
#               "numberOfDisks": 2,
#               "workloadType": "GENERAL",
#               "databaseEnginePort": "1433",
#               "probePortNumber": "59999",
#               "witnessStorageName": "${azurerm_storage_account.example.name}",
#               "witnessStorageKey": {
#                   "userName": "PLACEHOLDER-DO-NOT-USE",
#                   "password": "PrivateSettingsRef:witnessStorageKey"
#               },
#               "adminCreds": {
#                   "userName": "[parameters('adminUserName')]",
#                   "password": "PrivateSettingsRef:adminPassword"
#               },
#               "sqlServiceCreds": {
#                   "userName": "[parameters('sqlServiceAccount')]",
#                   "password": "PrivateSettingsRef:sqlServicePassword"
#               }
#           }
#       }
#   SETTINGS

#   protected_settings = <<SETTINGS
#       {
#         "items": {
#             "adminPassword": "P@ssW00rd!",
#             "sqlServicePassword": "P@ssW00rd!",
#             "witnessStorageKey": "${azurerm_storage_account.example.primary_access_key}"
#         }
#       }
#   SETTINGS
# }


locals {
  ips = "${azurerm_network_interface.example[*].private_ip_addresses[1]}"
  ips_json1 = "${jsonencode(local.ips)}"
}

output "ips" {
  value = "${local.ips}"
}
output "ips_json1" {
  value = "${local.ips_json1}"
}
