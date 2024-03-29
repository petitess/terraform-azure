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
  network_interface_ids = length(var.nic) == 1 ? [
    azurerm_network_interface.nicvm[var.nic[0].name].id
  ] : length(var.nic) == 2 ? [
    azurerm_network_interface.nicvm[var.nic[0].name].id,
    azurerm_network_interface.nicvm[var.nic[1].name].id
  ] : [
    azurerm_network_interface.nicvm[var.nic[0].name].id,
    azurerm_network_interface.nicvm[var.nic[1].name].id,
    azurerm_network_interface.nicvm[var.nic[2].name].id
  ]
  computer_name = var.name
  admin_username = var.admin_username
  admin_password = azurerm_key_vault_secret.vmsec.value
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
  for_each = {
    for nic in var.nic : nic.name => nic
    }
  name = "${var.name}-${each.value.name}"
  location = var.location
  tags = var.tags
  resource_group_name = azurerm_resource_group.rgvm.name
  ip_configuration {
    name = "config01"
    private_ip_address_allocation = each.value.private_ip_address_allocation
    private_ip_address = each.value.private_ip_address
    primary = each.value.primary
    subnet_id = "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rginfraname}/providers/Microsoft.Network/virtualNetworks/${var.vnetname}/subnets/${each.value.subnetname}"
    public_ip_address_id = each.value.publicip  ? azurerm_public_ip.vmpip[index(var.nic, each.value)].id : null
   }
}

resource "azurerm_public_ip" "vmpip" {
  for_each = {
    for nic, i in var.nic : nic => i
    if i.publicip 
    }
  name = "${var.name}-${each.value.name}-pip"
  location = var.location
  resource_group_name = azurerm_resource_group.rgvm.name
  tags = var.tags
  sku = "Standard"
  allocation_method = "Static"
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

resource "azurerm_backup_protected_vm" "vm" {
    count = var.rsvbackup ? 1 : 0
    backup_policy_id = var.rsvpolicyid
    recovery_vault_name = var.rsvname
    resource_group_name = var.rginfraname
    source_vm_id = azurerm_windows_virtual_machine.vm.id
}

resource "random_password" "vmsec" {
  length = 20
  special = true
  override_special = "!#$"
  min_lower = 1
  min_numeric = 1
  min_special = 1
  min_upper = 11
}

resource "azurerm_key_vault_secret" "vmsec" {
    name = var.name
    key_vault_id = var.kvid
    tags = var.tags
    value = random_password.vmsec.result
}