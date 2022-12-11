resource "azurerm_service_plan" "winplan" {
    name = "app-plan-${var.env}01"
    location = var.location
    tags = merge(var.tags, {
    Type = "My application"
    })
    resource_group_name = azurerm_resource_group.rginfra.name
    sku_name = "S1"
    os_type = "Windows"
}

resource "azurerm_windows_web_app" "winapp" {
    name = "app-${var.prefix}01"
    location = var.location
    tags = merge(var.tags, {
    Type = "My application"
    })
    resource_group_name = azurerm_resource_group.rginfra.name
    service_plan_id = azurerm_service_plan.winplan.id
    client_affinity_enabled = true
    https_only = true
    virtual_network_subnet_id = azurerm_subnet.app.id
    site_config {
      always_on = true
      ftps_state = "FtpsOnly"
      application_stack {
        dotnet_version = "v7.0"
      }
    }
  
}