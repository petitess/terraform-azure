resource "azurerm_resource_group" "rgvm" {
  name = "rg-${var.name}"
  location = var.location
  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "vm" {
  name = var.name
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm.name
  size = var.size
  network_interface_ids = [
     azurerm_network_interface.nicvm.id 
   ]
   computer_name = var.name
   admin_username = var.admin_username
   admin_password = var.admin_password
   os_disk {
     caching = "ReadWrite"
     storage_account_type = "Standard_LRS"
     disk_size_gb = var.os_disk_size_gb
   }
   source_image_reference {
    publisher = var.publisher
    offer = var.offer
    sku = var.sku
    version = var.versionx
   }
   identity {
     type = "SystemAssigned"
   }
}

resource "azurerm_network_interface" "nicvm" {
  name = "${var.name}-nic"
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm.name
  ip_configuration {
    name = "${var.name}-config01"
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address = var.private_ip_address
    primary = var.primary
    subnet_id = "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rginfraname}/providers/Microsoft.Network/virtualNetworks/${var.vnetname}/subnets/${var.subnetname}"
    public_ip_address_id = var.publicip ? azurerm_public_ip.vmpip[0].id : null
  }
}

resource "azurerm_managed_disk" "datadisk01" {
  for_each = {
    for datadisk in var.datadisk : datadisk.name => datadisk
    }
  name = "${var.name}-${each.value.name}"
  tags = var.tags
  location = var.location
  resource_group_name = azurerm_resource_group.rgvm.name
  storage_account_type = "Standard_LRS"
  create_option = "Empty"
  disk_size_gb = each.value.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk01_attach" {
  for_each = {
    for datadisk in var.datadisk : datadisk.name => datadisk
    }
  managed_disk_id = azurerm_managed_disk.datadisk01[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  lun = each.value.lun
  caching = "ReadWrite"
}

resource "azurerm_public_ip" "vmpip" {
  count = var.publicip ? 1 : 0 
  name = "${var.name}-pip"
  location = var.location
  resource_group_name = azurerm_resource_group.rgvm.name
  tags = var.tags
  sku = "Standard"
  allocation_method = "Static"
}

resource "azurerm_virtual_machine_extension" "ama" {
  count = var.AzureMonitorWindowsAgent ? 1 : 0 
  name = "AzureMonitorAgent"
  tags = var.tags
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  publisher = "Microsoft.Azure.Monitor"
  type = "AzureMonitorWindowsAgent"
  type_handler_version = "1.9"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled = true
  
  settings = <<SETTINGS
 {
  "authentication": {
        "managedIdentity": {
          "identifier-name":"mi_res_id",
          "identifier-value":"${azurerm_windows_virtual_machine.vm.id}"
          }
        }
 }
SETTINGS
}

resource "azurerm_monitor_data_collection_rule_association" "win" {
  count = var.AzureMonitorWindowsAgent ? 1 : 0 
  name = azurerm_windows_virtual_machine.vm.name
  data_collection_rule_id = var.data_collection_rule_id
  target_resource_id = azurerm_windows_virtual_machine.vm.id
}