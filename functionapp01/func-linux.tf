locals {

  func_config_linux = {
    always_on = false
    cors = {
      allowed_origins = ["https://portal.azure.com"]
    }
    app_settings = {
      WEBSITE_CONTENTOVERVNET                = "1"
      WEBSITE_CONTENTSHARE                   = "func"
      WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED = "1"
      WEBSITE_RUN_FROM_PACKAGE               = "1"
      FUNCTIONS_WORKER_RUNTIME               = "dotnet-isolated"
      WEBSITE_AUTH_AAD_ALLOWED_TENANTS       = data.azurerm_subscription.sub.tenant_id
    }
    versions_linux = {
      dotnet_version              = "8.0"
      use_dotnet_isolated_runtime = true
    }
    auth_client_id  = azuread_application.app.client_id
    auth_client_api = tolist(azuread_application.app.identifier_uris)[0]
  }
}

resource "azurerm_service_plan" "linux" {
  location            = local.location
  name                = "asp-linux-${local.prefix}-01"
  resource_group_name = azurerm_resource_group.func_linux.name
  sku_name            = "EP1"
  os_type             = "Linux"
}

resource "azurerm_linux_function_app" "linux" {
  depends_on                  = [azurerm_storage_account.linux]
  location                    = local.location
  name                        = "func-linux-${local.prefix}-01"
  resource_group_name         = azurerm_resource_group.func_linux.name
  service_plan_id             = azurerm_service_plan.linux.id
  storage_account_name        = azurerm_storage_account.linux.name
  storage_account_access_key  = azurerm_storage_account.linux.primary_access_key
  virtual_network_subnet_id   = azurerm_subnet.subnets["snet-func-outbound"].id
  app_settings                = lookup(local.func_config_linux, "app_settings", {})
  functions_extension_version = "~4"
  identity {
    type = "SystemAssigned"
  }
  site_config {
    always_on                              = lookup(local.func_config_linux, "always_on", true)
    use_32_bit_worker                      = lookup(local.func_config_linux, "use_32_bit_worker", true)
    http2_enabled                          = false
    ftps_state                             = "Disabled"
    pre_warmed_instance_count              = lookup(local.func_config_linux, "pre_warmed_instance_count", null)
    application_insights_connection_string = lookup(local.func_config_linux, "application_insights_connection_string", null)
    minimum_tls_version                    = "1.2"
    vnet_route_all_enabled                 = true
    application_stack {
      powershell_core_version     = lookup(local.func_config_linux.versions_linux, "powershell_core_version", null)
      java_version                = lookup(local.func_config_linux.versions_linux, "java_version", null)
      node_version                = lookup(local.func_config_linux.versions_linux, "node_version", null)
      dotnet_version              = lookup(local.func_config_linux.versions_linux, "dotnet_version", null)
      use_custom_runtime          = lookup(local.func_config_linux.versions_linux, "use_custom_runtime", null)
      use_dotnet_isolated_runtime = lookup(local.func_config_linux.versions_linux, "use_dotnet_isolated_runtime", false)
    }
    dynamic "cors" {
      for_each = local.func_config_linux.cors != null ? [1] : []
      content {
        allowed_origins     = lookup(local.func_config_linux.cors, "allowed_origins", null)
        support_credentials = lookup(local.func_config_linux.cors, "support_credentials", null)
      }
    }
    dynamic "ip_restriction" {
      for_each = lookup(local.func_config_linux, "ip_restriction", []) != [] ? lookup(local.func_config_linux, "ip_restriction") : []
      content {
        action                    = lookup(ip_restriction.value, "action", null)
        ip_address                = lookup(ip_restriction.value, "ip_address", null)
        name                      = lookup(ip_restriction.value, "name", null)
        priority                  = lookup(ip_restriction.value, "priority", null)
        service_tag               = lookup(ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(ip_restriction.value, "virtual_network_subnet_id", null)
        headers {
          x_azure_fdid      = lookup(ip_restriction.value.headers, "x_azure_fdid", [])
          x_fd_health_probe = lookup(ip_restriction.value.headers, "x_fd_health_probe", [])
          x_forwarded_for   = lookup(ip_restriction.value.headers, "x_forwarded_for", [])
          x_forwarded_host  = lookup(ip_restriction.value.headers, "x_forwarded_host", [])
        }
      }
    }
    dynamic "scm_ip_restriction" {
      for_each = lookup(local.func_config_linux, "scm_ip_restriction", []) != [] ? lookup(local.func_config_linux, "scm_ip_restriction") : []
      content {
        action                    = lookup(scm_ip_restriction.value, "action", null)
        ip_address                = lookup(scm_ip_restriction.value, "ip_address", null)
        name                      = lookup(scm_ip_restriction.value, "name", null)
        priority                  = lookup(scm_ip_restriction.value, "priority", null)
        service_tag               = lookup(scm_ip_restriction.value, "service_tag", null)
        virtual_network_subnet_id = lookup(scm_ip_restriction.value, "virtual_network_subnet_id", null)
        headers {
          x_azure_fdid      = lookup(scm_ip_restriction.value.headers, "x_azure_fdid", [])
          x_fd_health_probe = lookup(scm_ip_restriction.value.headers, "x_fd_health_probe", [])
          x_forwarded_for   = lookup(scm_ip_restriction.value.headers, "x_forwarded_for", [])
          x_forwarded_host  = lookup(scm_ip_restriction.value.headers, "x_forwarded_host", [])
        }
      }
    }
  }
  auth_settings_v2 {
    auth_enabled             = true
    unauthenticated_action   = "Return401"
    forward_proxy_convention = "NoProxy"
    http_route_api_prefix    = "/.auth"
    require_authentication   = true
    require_https            = true
    runtime_version          = "~1"
    active_directory_v2 {
      allowed_applications = [
        local.func_config_linux.auth_client_id
      ]
      allowed_audiences = [
        local.func_config_linux.auth_client_api
      ]
      allowed_identities   = []
      client_id            = local.func_config_linux.auth_client_id
      tenant_auth_endpoint = "https://sts.windows.net/${data.azurerm_subscription.sub.tenant_id}/v2.0"
    }
    login {
    }
  }
}

resource "azurerm_private_endpoint" "func-linux" {
  name                          = "pep-${azurerm_linux_function_app.linux.name}"
  location                      = local.location
  resource_group_name           = azurerm_linux_function_app.linux.resource_group_name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_linux_function_app.linux.name}"
  private_service_connection {
    name                           = "con-${azurerm_linux_function_app.linux.name}"
    private_connection_resource_id = azurerm_linux_function_app.linux.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "sites"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns[index(var.pdnsz, "privatelink.azurewebsites.net")].id]
  }
}
