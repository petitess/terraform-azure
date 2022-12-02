
locals {
  vmname = "vmweb${var.env}"
}

resource "azurerm_resource_group" "rgvm" {
  count = var.vmwebcount
  name = "rg-${local.vmname}0${count.index + 1}" 
  location = var.location
  tags = var.tags
}

resource "azurerm_network_interface" "nicvmweb" {
  count = var.vmwebcount
  name = "${local.vmname}0${count.index + 1}-nic"
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm[count.index].name
  ip_configuration {
    name = "config01"
    private_ip_address_allocation = "Static"
    private_ip_address = "10.0.7.${count.index + 10}"
    primary = true
    subnet_id = azurerm_subnet.app.id
  }
}

resource "azurerm_windows_virtual_machine" "vm01" {
  count = var.vmwebcount
  name = "${local.vmname}0${count.index + 1}"
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm[count.index].name
  size = "Standard_B2s"
  network_interface_ids = [
     azurerm_network_interface.nicvmweb[count.index].id 
   ]
   computer_name = "${local.vmname}0${count.index + 1}"
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
  count = var.vmwebcount
  name = "InstallIIS"
  publisher = "Microsoft.Compute"
  type = "CustomScriptExtension"
  type_handler_version = "1.10"
  auto_upgrade_minor_version = true
  virtual_machine_id = azurerm_windows_virtual_machine.vm01[count.index].id
  settings = <<SETTINGS
 {
  "commandToExecute": "powershell Add-WindowsFeature Web-Server"
 }
SETTINGS
}
