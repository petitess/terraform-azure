data "azurerm_resource_group" "existing" {
  for_each = {
    for key, f in var.function_apps : key => f
    if try(f.rg_name, null) != null
  }
  name = each.value.rg_name
}

resource "azurerm_resource_group" "func" {
  for_each = {
    for key, f in var.function_apps : key => f
    if try(f.rg_name, null) == null
  }
  name     = "rg-${each.key}"
  location = local.location
}

resource "azurerm_linux_function_app" "func" {
  for_each            = var.function_apps
  name                = each.key
  resource_group_name = try(azurerm_resource_group.func[each.key].name, data.azurerm_resource_group.existing[each.key].name)
  location            = local.location
  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id     = azurerm_subnet.subnets["snet-app"].id
  storage_account_name          = azurerm_storage_account.st_map[each.value.st_name].name
  storage_uses_managed_identity = true
  service_plan_id               = azurerm_service_plan.func.id
  https_only                    = true
  site_config {
    application_stack {
      python_version              = try(each.value.python_version, null)
      dotnet_version              = try(each.value.dotnet_version, null)
      java_version                = try(each.value.java_version, null)
      node_version                = try(each.value.node_version, null)
      powershell_core_version     = try(each.value.powershell_core_version, null)
      use_custom_runtime          = try(each.value.use_custom_runtime, null)
      use_dotnet_isolated_runtime = try(each.value.use_dotnet_isolated_runtime, null)
    }
    cors {
      support_credentials = false
      allowed_origins     = ["https://portal.azure.com"]
    }
    http2_enabled                          = false
    remote_debugging_enabled               = false
    websockets_enabled                     = false
    ftps_state                             = "Disabled"
    minimum_tls_version                    = "1.2"
    vnet_route_all_enabled                 = true
    always_on                              = true
    use_32_bit_worker                      = false
    pre_warmed_instance_count              = 1
    application_insights_connection_string = try(sensitive(azurerm_application_insights.appi.connection_string), null)
    ip_restriction_default_action          = "Allow"
    scm_ip_restriction_default_action      = "Allow"
  }

  app_settings = merge({
    AzureFunctionsWebHost__hostid = replace(uuidv5("oid", "${each.key}.azurewebsites.net"), "-", "")
  }, try(each.value.app_settings, null))

  dynamic "auth_settings_v2" {
    for_each = try(each.value.auth_settings_v2, null) != null ? [each.value.auth_settings_v2] : []
    content {
      auth_enabled                            = try(auth_settings_v2.value.auth_enabled, null)
      unauthenticated_action                  = try(auth_settings_v2.value.unauthenticated_action, null)
      forward_proxy_convention                = try(auth_settings_v2.value.forward_proxy_convention, null)
      http_route_api_prefix                   = try(auth_settings_v2.value.http_route_api_prefix, null)
      require_authentication                  = try(auth_settings_v2.value.require_authentication, null)
      require_https                           = try(auth_settings_v2.value.require_https, null)
      runtime_version                         = try(auth_settings_v2.value.runtime_version, null)
      excluded_paths                          = try(auth_settings_v2.value.excluded_paths, null)
      default_provider                        = try(auth_settings_v2.value.default_provider, null)
      forward_proxy_custom_host_header_name   = try(auth_settings_v2.value.forward_proxy_custom_host_header_name, null)
      forward_proxy_custom_scheme_header_name = try(auth_settings_v2.value.forward_proxy_custom_scheme_header_name, null)
      active_directory_v2 {
        client_secret_setting_name      = try(auth_settings_v2.value.client_secret_setting_name, null)
        allowed_applications            = try(auth_settings_v2.value.allowed_applications, null)
        allowed_groups                  = try(auth_settings_v2.value.allowed_groups, null)
        allowed_identities              = try(auth_settings_v2.value.allowed_identities, null)
        client_id                       = try(auth_settings_v2.value.client_id, null)
        jwt_allowed_client_applications = try(auth_settings_v2.value.jwt_allowed_client_applications, null)
        jwt_allowed_groups              = try(auth_settings_v2.value.jwt_allowed_groups, null)
        login_parameters                = try(auth_settings_v2.value.login_parameters, null)
        tenant_auth_endpoint            = try(auth_settings_v2.value.tenant_auth_endpoint, null)
        www_authentication_disabled     = try(auth_settings_v2.value.www_authentication_disabled, null)
        allowed_audiences               = try(auth_settings_v2.value.allowed_audiences, null)
      }
      login {
        token_refresh_extension_time      = try(auth_settings_v2.value.token_refresh_extension_time, null)
        token_store_enabled               = try(auth_settings_v2.value.token_store_enabled, null)
        token_store_path                  = try(auth_settings_v2.value.token_store_path, null)
        allowed_external_redirect_urls    = try(auth_settings_v2.value.allowed_external_redirect_urls, null)
        cookie_expiration_convention      = try(auth_settings_v2.value.cookie_expiration_convention, null)
        cookie_expiration_time            = try(auth_settings_v2.value.cookie_expiration_time, null)
        logout_endpoint                   = try(auth_settings_v2.value.logout_endpoint, null)
        nonce_expiration_time             = try(auth_settings_v2.value.nonce_expiration_time, null)
        preserve_url_fragments_for_logins = try(auth_settings_v2.value.preserve_url_fragments_for_logins, null)
        token_store_sas_setting_name      = try(auth_settings_v2.value.token_store_sas_setting_name, null)
        validate_nonce                    = try(auth_settings_v2.value.validate_nonce, null)
      }
    }
  }

  lifecycle {
    ignore_changes = [tags["hidden-link: /app-insights-resource-id"]]
  }
}

resource "azurerm_linux_function_app_slot" "slot" {
  # for_each            = var.function_apps
  for_each = {
    for key, f in var.function_apps : key => f
    if try(f.slot, null) != null
  }
  name                          = each.value.slot.name
  function_app_id               = azurerm_linux_function_app.func[each.key].id
  storage_account_name          = azurerm_storage_account.st_map[each.value.st_name].name
  storage_uses_managed_identity = true

  identity {
    type = "SystemAssigned"
  }

  virtual_network_subnet_id = azurerm_subnet.subnets["snet-app"].id

  site_config {
    application_stack {
      python_version              = try(each.value.python_version, null)
      dotnet_version              = try(each.value.dotnet_version, null)
      java_version                = try(each.value.java_version, null)
      node_version                = try(each.value.node_version, null)
      powershell_core_version     = try(each.value.powershell_core_version, null)
      use_custom_runtime          = try(each.value.use_custom_runtime, null)
      use_dotnet_isolated_runtime = try(each.value.use_dotnet_isolated_runtime, null)
    }
    cors {
      support_credentials = false
      allowed_origins     = ["https://portal.azure.com"]
    }
    http2_enabled                          = false
    remote_debugging_enabled               = false
    websockets_enabled                     = false
    ftps_state                             = "Disabled"
    minimum_tls_version                    = "1.2"
    vnet_route_all_enabled                 = true
    always_on                              = true
    use_32_bit_worker                      = false
    pre_warmed_instance_count              = 1
    application_insights_connection_string = try(sensitive(azurerm_application_insights.appi.connection_string), null)
    ip_restriction_default_action          = "Allow"
    scm_ip_restriction_default_action      = "Allow"
  }

  app_settings = merge({
    AzureFunctionsWebHost__hostid = replace(uuidv5("oid", "${each.key}-slot.azurewebsites.net"), "-", "")
  }, try(each.value.app_settings, null))

  dynamic "auth_settings_v2" {
    for_each = try(each.value.auth_settings_v2, null) != null ? [each.value.auth_settings_v2] : []
    content {
      auth_enabled                            = try(auth_settings_v2.value.auth_enabled, null)
      unauthenticated_action                  = try(auth_settings_v2.value.unauthenticated_action, null)
      forward_proxy_convention                = try(auth_settings_v2.value.forward_proxy_convention, null)
      http_route_api_prefix                   = try(auth_settings_v2.value.http_route_api_prefix, null)
      require_authentication                  = try(auth_settings_v2.value.require_authentication, null)
      require_https                           = try(auth_settings_v2.value.require_https, null)
      runtime_version                         = try(auth_settings_v2.value.runtime_version, null)
      excluded_paths                          = try(auth_settings_v2.value.excluded_paths, null)
      default_provider                        = try(auth_settings_v2.value.default_provider, null)
      forward_proxy_custom_host_header_name   = try(auth_settings_v2.value.forward_proxy_custom_host_header_name, null)
      forward_proxy_custom_scheme_header_name = try(auth_settings_v2.value.forward_proxy_custom_scheme_header_name, null)
      active_directory_v2 {
        client_secret_setting_name      = try(auth_settings_v2.value.client_secret_setting_name, null)
        allowed_applications            = try(auth_settings_v2.value.allowed_applications, null)
        allowed_groups                  = try(auth_settings_v2.value.allowed_groups, null)
        allowed_identities              = try(auth_settings_v2.value.allowed_identities, null)
        client_id                       = try(auth_settings_v2.value.client_id, null)
        jwt_allowed_client_applications = try(auth_settings_v2.value.jwt_allowed_client_applications, null)
        jwt_allowed_groups              = try(auth_settings_v2.value.jwt_allowed_groups, null)
        login_parameters                = try(auth_settings_v2.value.login_parameters, null)
        tenant_auth_endpoint            = try(auth_settings_v2.value.tenant_auth_endpoint, null)
        www_authentication_disabled     = try(auth_settings_v2.value.www_authentication_disabled, null)
        allowed_audiences               = try(auth_settings_v2.value.allowed_audiences, null)
      }
      login {
        token_refresh_extension_time      = try(auth_settings_v2.value.token_refresh_extension_time, null)
        token_store_enabled               = try(auth_settings_v2.value.token_store_enabled, null)
        token_store_path                  = try(auth_settings_v2.value.token_store_path, null)
        allowed_external_redirect_urls    = try(auth_settings_v2.value.allowed_external_redirect_urls, null)
        cookie_expiration_convention      = try(auth_settings_v2.value.cookie_expiration_convention, null)
        cookie_expiration_time            = try(auth_settings_v2.value.cookie_expiration_time, null)
        logout_endpoint                   = try(auth_settings_v2.value.logout_endpoint, null)
        nonce_expiration_time             = try(auth_settings_v2.value.nonce_expiration_time, null)
        preserve_url_fragments_for_logins = try(auth_settings_v2.value.preserve_url_fragments_for_logins, null)
        token_store_sas_setting_name      = try(auth_settings_v2.value.token_store_sas_setting_name, null)
        validate_nonce                    = try(auth_settings_v2.value.validate_nonce, null)
      }
    }
  }

  lifecycle {
    ignore_changes = [tags["hidden-link: /app-insights-resource-id"]]
  }
}

resource "azurerm_private_endpoint" "func-linux" {
  for_each                      = var.function_apps
  name                          = "pep-${azurerm_linux_function_app.func[each.key].name}"
  location                      = local.location
  resource_group_name           = azurerm_linux_function_app.func[each.key].resource_group_name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_linux_function_app.func[each.key].name}"
  private_service_connection {
    name                           = "con-${azurerm_linux_function_app.func[each.key].name}"
    private_connection_resource_id = azurerm_linux_function_app.func[each.key].id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "ipconfig"
    member_name        = "sites"
    private_ip_address = each.value.pep_ip_address
    subresource_name   = "sites"
  }

  private_dns_zone_group {
    name                 = "sites"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.azurewebsites.net")].id]
  }
}

resource "azurerm_private_endpoint" "func-linux-slot" {
  for_each = {
    for key, f in var.function_apps : key => f
    if try(f.slot, null) != null
  }
  name                          = "pep-${azurerm_linux_function_app.func[each.key].name}-${each.value.slot.name}"
  location                      = local.location
  resource_group_name           = azurerm_linux_function_app.func[each.key].resource_group_name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_linux_function_app.func[each.key].name}-${each.value.slot.name}"
  private_service_connection {
    name                           = "con-${azurerm_linux_function_app.func[each.key].name}"
    private_connection_resource_id = azurerm_linux_function_app.func[each.key].id
    subresource_names              = ["sites-${each.value.slot.name}"]
    is_manual_connection           = false
  }

  ip_configuration {
    name               = "ipconfig"
    member_name        = "sites-${each.value.slot.name}"
    private_ip_address = each.value.slot.pep_ip_address
    subresource_name   = "sites-${each.value.slot.name}"
  }

  private_dns_zone_group {
    name                 = "sites-${each.value.slot.name}"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.azurewebsites.net")].id]
  }
}

resource "azurerm_role_assignment" "func" {
  for_each             = var.function_apps
  scope                = try(azurerm_resource_group.func[each.key].id, data.azurerm_resource_group.existing[each.key].id)
  principal_id         = azurerm_linux_function_app.func[each.key].identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "func_mon" {
  for_each             = var.function_apps
  scope                = try(azurerm_resource_group.func_commmon.id, data.azurerm_resource_group.existing[each.key].id)
  principal_id         = azurerm_linux_function_app.func[each.key].identity[0].principal_id
  role_definition_name = "Monitoring Metrics Publisher"
}

resource "azurerm_role_assignment" "func_kv" {
  for_each             = var.function_apps
  scope                = try(azurerm_resource_group.func[each.key].id, data.azurerm_resource_group.existing[each.key].id)
  principal_id         = azurerm_linux_function_app.func[each.key].identity[0].principal_id
  role_definition_name = "Key Vault Administrator"
}

resource "azurerm_role_assignment" "func-slot" {
  for_each = {
    for key, f in var.function_apps : key => f
    if try(f.slot, null) != null
  }
  scope                = try(azurerm_resource_group.func[each.key].id, data.azurerm_resource_group.existing[each.key].id)
  principal_id         = azurerm_linux_function_app_slot.slot[each.key].identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "func_mon-slot" {
  for_each = {
    for key, f in var.function_apps : key => f
    if try(f.slot, null) != null
  }
  scope                = try(azurerm_resource_group.func_commmon.id, data.azurerm_resource_group.existing[each.key].id)
  principal_id         = azurerm_linux_function_app_slot.slot[each.key].identity[0].principal_id
  role_definition_name = "Monitoring Metrics Publisher"
}

resource "azurerm_role_assignment" "func_kv-slot" {
  for_each = {
    for key, f in var.function_apps : key => f
    if try(f.slot, null) != null
  }
  scope                = try(azurerm_resource_group.func[each.key].id, data.azurerm_resource_group.existing[each.key].id)
  principal_id         = azurerm_linux_function_app_slot.slot[each.key].identity[0].principal_id
  role_definition_name = "Key Vault Administrator"
}
