resource "azurerm_resource_group" "rgvm" {
  name = "rgx-vm01" 
  location = var.location
  tags = var.tags
}

resource "azurerm_public_ip" "pipvm" {
  name = "vm01-pip"
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_network_interface" "nicvm" {
  name = "vm01-nic"
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm.name
  ip_configuration {
    name = "config01"
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.7.10"
    primary = true
    public_ip_address_id = azurerm_public_ip.pipvm.id
    subnet_id = azurerm_subnet.app.id
  }
}

# resource "azurerm_managed_disk" "vmosdisk" {
#   name                 = "vm01-osdisk"
#   location             = azurerm_resource_group.rgvm.location
#   resource_group_name  = azurerm_resource_group.rgvm.name
#   storage_account_type = "Standard_LRS"
#   create_option        = "FromImage"
#   disk_size_gb         = "127"
#   image_reference_id = azurerm_virtual_machine.vm01.
#   tags = var.tags
# }

resource "azurerm_windows_virtual_machine" "vm01" {
  name = "vm01"
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm.name
  size = "Standard_B2s"
  network_interface_ids = [
     azurerm_network_interface.nicvm.id 
   ]
   computer_name = "vm01"
   admin_username = "azadmin"
   admin_password = "12345678.abc"
   os_disk {
     caching = "ReadWrite"
     storage_account_type = "Standard_LRS"
   }
   source_image_reference {
     publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
   }
}