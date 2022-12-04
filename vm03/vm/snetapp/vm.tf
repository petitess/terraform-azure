resource "azurerm_resource_group" "rgvm" {
  for_each = var.vms-snetapp
  name = "rg-${each.value.name}" 
  location = var.location
  tags = each.value.tags
}

resource "azurerm_network_interface" "nicvm" {
  for_each = var.vms-snetapp
  name = "${each.value.name}-nic"
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm[each.key].name
  ip_configuration {
    name = "config01"
    private_ip_address_allocation = "Static"
    private_ip_address = each.value.networkInterfaces.private_ip_address
    primary = true
    subnet_id = var.snetappid
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each = var.vms-snetapp
  name = each.value.name
  location = var.location
  tags = each.value.tags
  resource_group_name = azurerm_resource_group.rgvm[each.key].name
  size = each.value.size
  network_interface_ids = [
     azurerm_network_interface.nicvm[each.key].id 
   ]
   computer_name = each.value.name
   admin_username = "azadmin"
   admin_password = "12345678.abc"
   os_disk {
     caching = "ReadWrite"
     storage_account_type = "Standard_LRS"
     disk_size_gb = each.value.osdisksize

   }
   source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
   }
}
