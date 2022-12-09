locals {
//Put Container Config string below. You find it on Server container in Google Tag Manager
  containerconfig = "xxxxxdCMzk4ODUmZW52PTEmYXV0aD1CNUdxWFlMeXozLUhaxxxxxxxx"
}

resource "azurerm_service_plan" "plan1" {
    name = "app-gtm-plan-${var.env}01"
    location = var.location
    tags = merge(var.tags, {
    Type = "Preview server"
  })
    resource_group_name = azurerm_resource_group.rgapp.name
    sku_name = "B1"
    os_type = "Linux"
}

resource "azurerm_linux_web_app" "app1" {
    name = "app-gtm-${var.env}01"
    location = var.location
    tags = merge(var.tags, {
    Type = "Preview server"
  })
    resource_group_name = azurerm_resource_group.rgapp.name
    service_plan_id = azurerm_service_plan.plan1.id
    client_affinity_enabled = false
    https_only = true 
    site_config {
        app_command_line = ""
        always_on = false
        ftps_state = "FtpsOnly"
        health_check_path = "/healthz"
        minimum_tls_version = "1.2"
        application_stack {
          docker_image = "gcr.io/cloud-tagging-10302018/gtm-cloud-image"
          docker_image_tag = "stable"
        }
    }
    app_settings = {
        DOCKER_REGISTRY_SERVER_URL = "https://index.docker.io"
        DOCKER_REGISTRY_SERVER_USERNAME = ""
        DOCKER_REGISTRY_SERVER_PASSWORD = ""
        WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
        RUN_AS_PREVIEW_SERVER = true
        CONTAINER_CONFIG = local.containerconfig
    }
}

resource "azurerm_service_plan" "plan2" {
    name = "app-gtm-plan-${var.env}02"
    location = var.location
    tags = merge(var.tags, {
    Type = "Tagging server"
  })
    resource_group_name = azurerm_resource_group.rgapp.name
    sku_name = "S1"
    os_type = "Linux"
}

resource "azurerm_linux_web_app" "app2" {
    name = "app-gtm-${var.env}02"
    location = var.location
    tags = merge(var.tags, {
    Type = "Tagging server"
    })
    resource_group_name = azurerm_resource_group.rgapp.name
    service_plan_id = azurerm_service_plan.plan2.id
    client_affinity_enabled = false
    https_only = true 
    site_config {
        app_command_line = ""
        always_on = false
        ftps_state = "FtpsOnly"
        health_check_path = "/healthz"
        minimum_tls_version = "1.2"
        application_stack {
          docker_image = "gcr.io/cloud-tagging-10302018/gtm-cloud-image"
          docker_image_tag = "stable"
        }
    }
    app_settings = {
        DOCKER_REGISTRY_SERVER_URL = "https://index.docker.io"
        DOCKER_REGISTRY_SERVER_USERNAME = ""
        DOCKER_REGISTRY_SERVER_PASSWORD = ""
        WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
        PREVIEW_SERVER_URL = "https://${azurerm_linux_web_app.app1.name}.azurewebsites.net"
        CONTAINER_CONFIG = local.containerconfig
    }
}

resource "azurerm_monitor_autoscale_setting" "scale" {
    name = "${azurerm_linux_web_app.app2.name}-autoscale01"
    location = var.location
    tags = merge(var.tags, {
    Type = "Tagging server"
    })
    resource_group_name = azurerm_resource_group.rgapp.name
    enabled = true
    target_resource_id = azurerm_service_plan.plan2.id
    profile {
      name = "Condition01"
      capacity {
        default = 1
        maximum = 5
        minimum = 1
      }
      rule {
        metric_trigger {
          metric_name = "CpuPercentage"
          metric_namespace = "microsoft.web/serverfarms"
          metric_resource_id = azurerm_service_plan.plan2.id
          time_grain = "PT1M"
          statistic = "Average"
          time_window = "PT10M"
          time_aggregation = "Average"
          operator = "GreaterThan"
          threshold = 70
          divide_by_instance_count = false  
        }
        scale_action {
          direction = "Increase"
          type = "ChangeCount"
          value = 1
          cooldown = "PT5M"
        }
      }
      rule {
        metric_trigger {
          metric_name = "CpuPercentage"
          metric_namespace = "microsoft.web/serverfarms"
          metric_resource_id = azurerm_service_plan.plan2.id
          time_grain = "PT1M"
          statistic = "Average"
          time_window = "PT10M"
          time_aggregation = "Average"
          operator = "LessThan"
          threshold = 70
          divide_by_instance_count = false  
        }
        scale_action {
          direction = "Decrease"
          type = "ChangeCount"
          value = 1
          cooldown = "PT5M"
        }
      }
    }
}