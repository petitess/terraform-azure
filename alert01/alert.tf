resource "azurerm_monitor_activity_log_alert" "alert01" {
    name = "ServiceHealth_Information"
    tags = var.tags
    resource_group_name = azurerm_resource_group.rginfra.name
    scopes = [ data.azurerm_subscription.current.id ]
    enabled = true
    # action {
    #   action_group_id = 
    # }
    criteria {
        category = "ServiceHealth"
        service_health {
            locations = [ "global", "Sweden Central" ]
            events = [ "Maintenance" ]
            services = null
        }
    }
}

resource "azurerm_monitor_activity_log_alert" "alert02" {
    name = "ServiceHealth_Warning"
    tags = var.tags
    resource_group_name = azurerm_resource_group.rginfra.name
    scopes = [ data.azurerm_subscription.current.id ]
    enabled = true
    # action {
    #   action_group_id = 
    # }
    criteria {
        category = "ServiceHealth"
        service_health {
            locations = [ "global", "Sweden Central" ]
            events = [ "Incident", "Security" ]
            services = [
              "Activity Logs & Alerts",
              "Action Groups",
              "Alerts",
              "Alerts & Metrics",
              "Automation",
              "Azure Active Directory",
              "Azure Bastion",
              "Azure DNS",
              "Azure DevOps",
              "Azure DevOps \\ Artifacts",
              "Azure DevOps \\ Boards",
              "Azure DevOps \\ Pipelines",
              "Azure DevOps \\ Repos",
              "Azure DevOps \\ Test Plans",
              "Azure Key Vault Managed HSM",
              "Azure Monitor",
              "Azure Private Link",
              "Azure Resource Manager",
              "Recovery Services vault",
              "Backup vault",
              "Cloud Services",
              "Cloud Shell",
              "Cost Management",
              "Key Vault",
              "Log Analytics",
              "Marketplace",
              "Microsoft Azure portal",
              "Microsoft Azure portal \\ Marketplace",
              "Microsoft Defender for Cloud",
              "Multi-Factor Authentication",
              "Network Infrastructure",
              "Network Watcher",
              "SQL Server on Azure Virtual Machines",
              "Scheduler",
              "Security Center",
              "Storage",
              "Subscription Management",
              "VPN Gateway",
              "VPN Gateway \\ Virtual WAN",
              "Virtual Machines",
              "Virtual Network",
              "Windows Virtual Desktop",
            ]
        }
    }
}