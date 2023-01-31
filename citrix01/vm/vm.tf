resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  location            = var.location
  tags                = var.tags
  resource_group_name = var.rgname
  size                = var.size
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
  computer_name                   = var.name
  disable_password_authentication = false
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }
  source_image_reference {
    publisher = var.publisher
    offer     = var.offer
    sku       = var.sku
    version   = var.versionx
  }
  plan {
    name      = var.planname
    product   = var.planproduct
    publisher = var.planpublisher
  }
  identity {
    type = "SystemAssigned"
  }
  availability_set_id = var.availname != "" ? "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rgname}/providers/Microsoft.Compute/availabilitySets/${var.availname}" : null
}

resource "azurerm_network_interface" "nicvm" {
  for_each = {
    for nic in var.nic : nic.name => nic
  }
  name                          = "${var.name}-${each.value.name}"
  location                      = var.location
  tags                          = var.tags
  resource_group_name           = var.rgname
  enable_accelerated_networking = each.value.accelerated_networking
  ip_configuration {
    name                          = "config01"
    private_ip_address_allocation = each.value.private_ip_address_allocation
    private_ip_address            = each.value.private_ip_address
    primary                       = each.value.primary
    subnet_id                     = "${data.azurerm_subscription.sub.id}/resourceGroups/${var.rginfraname}/providers/Microsoft.Network/virtualNetworks/${var.vnetname}/subnets/${each.value.subnetname}"
    public_ip_address_id          = each.value.publicip ? azurerm_public_ip.vmpip[index(var.nic, each.value)].id : null
  }
}

resource "azurerm_public_ip" "vmpip" {
  for_each = {
    for nic, i in var.nic : nic => i
    if i.publicip
  }
  name                = "${var.name}-${each.value.name}-pip"
  location            = var.location
  resource_group_name = var.rgname
  tags                = var.tags
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_managed_disk" "datadisk01" {
  for_each = {
    for datadisk in var.datadisk : datadisk.name => datadisk
  }
  name                 = "${var.name}-${each.value.name}"
  tags                 = var.tags
  location             = var.location
  resource_group_name  = var.rgname
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value.disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk01_attach" {
  for_each = {
    for datadisk in var.datadisk : datadisk.name => datadisk
  }
  managed_disk_id    = azurerm_managed_disk.datadisk01[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = each.value.lun
  caching            = "ReadWrite"
}

resource "azurerm_network_interface_backend_address_pool_association" "vmext" {
  for_each = {
    for nic, i in var.nic : nic => i
    if i.externalLB
  }
  network_interface_id    = azurerm_network_interface.nicvm[each.value.name].id
  ip_configuration_name   = azurerm_network_interface.nicvm[each.value.name].ip_configuration[0].name
  backend_address_pool_id = var.externalLBid
}

resource "azurerm_network_interface_backend_address_pool_association" "vmint" {
  for_each = {
    for nic, i in var.nic : nic => i
    if i.internalLB
  }
  network_interface_id    = azurerm_network_interface.nicvm[each.value.name].id
  ip_configuration_name   = azurerm_network_interface.nicvm[each.value.name].ip_configuration[0].name
  backend_address_pool_id = var.internalLBid
}
