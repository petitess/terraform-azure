resource "azurerm_resource_group" "rgvm" {
  name = "rg-${var.name}"
  location = var.location
  tags = var.tags
}

resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
    name = var.name
    location = var.location
    tags = var.tags
    resource_group_name = azurerm_resource_group.rgvm.name
    sku = var.size
    instances = var.instances
    admin_username = var.admin_username
    admin_password = var.admin_password
    network_interface {
      name = azurerm_network_interface.nicvm.name
      primary = true
      ip_configuration {
        name = "ipconfig01"
        primary = true
        subnet_id = var.subnet_id
      }
    }
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
    data_disk {
      create_option = "Empty"
      disk_size_gb = 10
      lun = 1
      storage_account_type = "Standard_LRS"
      caching = "ReadWrite"
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
    subnet_id = var.subnet_id
    public_ip_address_id = var.publicip ? azurerm_public_ip.vmpip[0].id : null
  }
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

resource "azurerm_monitor_autoscale_setting" "vmas" {
  name = "vmss-autoscaling01"
  location = var.location
  resource_group_name = azurerm_resource_group.rgvm.name
  target_resource_id = azurerm_windows_virtual_machine_scale_set.vmss.id
  enabled = true
  notification {
    email {
      send_to_subscription_administrator = false
      send_to_subscription_co_administrator = false
      custom_emails = [ "name@mail.com" ]
    }
  }
  profile {
    name = "default"
    capacity {
      default = 2
      maximum = 5
      minimum = 2
    }
    rule {
      scale_action {
        direction = "Increase"
        type = "ChangeCount"
        value = 1
        cooldown = "PT5M"
      }
      metric_trigger {
        metric_name = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vmss.id
        metric_namespace = "microsoft.compute/virtualmachinescalesets"
        time_grain = "PT1M"
        statistic = "Average"
        time_window = "PT5M"
        time_aggregation = "Average"
        operator = "GreaterThan"
        threshold = 75
      }
    }
    rule {
      scale_action {
        direction = "Decrease"
        type = "ChangeCount"
        value = 1
        cooldown = "PT5M"
      }
      metric_trigger {
        metric_name = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.vmss.id
        metric_namespace = "microsoft.compute/virtualmachinescalesets"
        time_grain = "PT1M"
        statistic = "Average"
        time_window = "PT5M"
        time_aggregation = "Average"
        operator = "LessThan"
        threshold = 35
      }
    }
  }
}