locals {
  private_cluster             = false
  ingress_application_gateway = false
  node_pools = {
    # "pool01" = {
    #   name       = "pool01"
    #   vm_size    = "Standard_B2ms"
    #   node_count = 1
    # }
  }
  logs = [
    "kube-apiserver",
    "kube-controller-manager",
    "kube-scheduler",
    "kube-audit"
  ]
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-aks-${var.env}-01"
  location = local.location
  tags     = local.tags
}
//For private cluster
resource "azurerm_private_dns_zone" "aks" {
  count               = local.private_cluster ? 1 : 0
  name                = "privatelink.swedencentral.azmk8s.io"
  resource_group_name = azurerm_resource_group.aks.name
}
//For private cluster
resource "azurerm_user_assigned_identity" "aks" {
  count               = local.private_cluster ? 1 : 0
  name                = "id-aks-${var.env}-01"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  tags                = local.tags
}
//For private cluster
resource "azurerm_role_assignment" "aks_dns" {
  count                = local.private_cluster ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_resource_group.aks.id
}
//For private cluster
resource "azurerm_role_assignment" "aks_vnet" {
  count                = local.private_cluster ? 1 : 0
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_resource_group.hub.id
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                                = "aks-${var.env}-01"
  location                            = azurerm_resource_group.aks.location
  resource_group_name                 = azurerm_resource_group.aks.name
  dns_prefix                          = "aks${var.env}01"
  tags                                = local.tags
  node_resource_group                 = "rg-aks-${var.env}-02"
  local_account_disabled              = true
  private_cluster_enabled             = local.private_cluster ? true : false
  private_dns_zone_id                 = local.private_cluster ? azurerm_private_dns_zone.aks[0].id : null
  private_cluster_public_fqdn_enabled = local.private_cluster ? true : false
  identity {
    type         = local.private_cluster ? "UserAssigned" : "SystemAssigned"
    identity_ids = local.private_cluster ? [azurerm_user_assigned_identity.aks[0].id] : []
  }
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }
  default_node_pool {
    orchestrator_version        = "1.30"
    tags                        = local.tags
    name                        = "default"
    node_count                  = 2
    vm_size                     = "Standard_D2s_v3"
    vnet_subnet_id              = azurerm_subnet.subnets["snet-aks"].id
    auto_scaling_enabled        = false
    type                        = "VirtualMachineScaleSets"
    temporary_name_for_rotation = "default"
    max_pods                    = 30
    max_count                   = null
    os_disk_size_gb             = 127
    os_disk_type                = "Managed"
    //only_critical_addons_enabled = true
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }
  network_profile {
    network_plugin      = "azure"
    service_cidr        = "10.0.0.0/16"
    dns_service_ip      = "10.0.0.10"
    network_plugin_mode = true ? null : "overlay"
    load_balancer_profile {
      backend_pool_type         = "NodeIPConfiguration"
      managed_outbound_ip_count = 1
      idle_timeout_in_minutes   = 30
    }
  }

  aci_connector_linux {
    subnet_name = "snet-aks-aci"
  }
  storage_profile {
    blob_driver_enabled = true
    file_driver_enabled = true
  }
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }
  //For grafana
  monitor_metrics {
  }
  dynamic "ingress_application_gateway" {
    for_each = local.ingress_application_gateway ? [1] : []
    content {
      gateway_name = "agw-aks-${var.env}-01"
      subnet_id    = azurerm_subnet.subnets["snet-aks-agic"].id
    }
  }
}
//For virtual nodes
resource "azurerm_role_assignment" "aks_virtual_nodes" {
  principal_id         = azurerm_kubernetes_cluster.aks.aci_connector_linux[0].connector_identity[0].object_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_virtual_network.vnet.id
}
//For private file storage - dns
resource "azurerm_role_assignment" "aks_pdnsz" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.hub.id
}
//For provided storage account
resource "azurerm_role_assignment" "aks_file" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.aks.id
}
//For azure contariner registry
resource "azurerm_role_assignment" "aks_acr" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPush"
  scope                = "/subscriptions/${var.subid}"
}
//For application gateway
resource "azurerm_role_assignment" "aks_agw" {
  count                = local.ingress_application_gateway ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.aks.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
  role_definition_name = "Network Contributor"
  scope                = azurerm_resource_group.hub.id
}

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  for_each              = local.node_pools
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  name                  = each.value["name"]
  vm_size               = each.value["vm_size"]
  node_count            = each.value["node_count"]
  orchestrator_version  = azurerm_kubernetes_cluster.aks.default_node_pool[0].orchestrator_version
  tags                  = local.tags
  os_disk_size_gb       = 64
  os_disk_type          = "Managed"
  os_sku                = "Ubuntu"
  os_type               = "Linux"
  vnet_subnet_id        = azurerm_subnet.subnets["snet-aks"].id
  max_pods              = 30
  max_count             = null
  auto_scaling_enabled  = false
  upgrade_settings {
    drain_timeout_in_minutes      = 0
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 0
  }
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  count                      = 0
  name                       = "diag-aks-${var.env}-01"
  target_resource_id         = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  metric {
    category = "AllMetrics"
    enabled  = false
  }
  dynamic "enabled_log" {
    for_each = local.logs
    content {
      category = enabled_log.value
    }
  }
}
