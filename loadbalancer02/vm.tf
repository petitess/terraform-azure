
locals {
  vmname = "vmweb${var.env}01"
}

resource "azurerm_resource_group" "rgvm" {
  name = "rg-${local.vmname}" 
  location = var.location
  tags = var.tags
}

# resource "azurerm_public_ip" "pipvm" {
#   name = "${local.vmname}-pip"
#   location = var.location
#   tags = var.tags
#   resource_group_name = azurerm_resource_group.rgvm.name
#   allocation_method = "Static"
#   sku = "Standard"
# }

resource "azurerm_network_interface" "nicvmweb" {
  name = "${local.vmname}-nic"
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm.name
  ip_configuration {
    name = "config01"
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.7.10"
    primary = true
    # public_ip_address_id = azurerm_public_ip.pipvm.id
    subnet_id = azurerm_subnet.app.id
  }
}

resource "azurerm_windows_virtual_machine" "vm01" {
  name = local.vmname
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm.name
  size = "Standard_B2s"
  network_interface_ids = [
     azurerm_network_interface.nicvmweb.id 
   ]
   computer_name = local.vmname
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

resource "azurerm_virtual_machine_extension" "vmps" {
  name = "InstallIIS"
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.10"
  auto_upgrade_minor_version = true
  virtual_machine_id = azurerm_windows_virtual_machine.vm01.id
  settings = <<SETTINGS
 {
  "commandToExecute": "powershell Add-WindowsFeature Web-Server"
 }
SETTINGS
}
