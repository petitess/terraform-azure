variable "env" {
  type    = string
  default = "dev"
}
variable "subid" {
  type    = string
  default = "abc"
}

variable "st_map" {
  type = map(object({
    name                          = string
    rg_name                       = optional(string)
    account_kind                  = string
    account_replication_type      = string
    access_tier                   = string
    public_network_access_enabled = bool
    allowed_ips                   = list(string)
    containers                    = optional(list(string))
    shares                        = optional(list(string))
    queues                        = optional(list(string))
    tables                        = optional(list(string))
    private_endpoints = optional(object({
      blob  = optional(string)
      file  = optional(string)
      table = optional(string)
      queue = optional(string)
    }))
  }))

  default = {
    "stfuncrepublik01" = {
      name                          = "stfuncrepublik01"
      rg_name                       = "ex=rg-func-republik01"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      public_network_access_enabled = true
      allowed_ips                   = ["1.150.118.1"]
      containers                    = ["con12", "con34"]
      shares                        = ["func-code"]
      tables                        = ["t12", "t34"]
      private_endpoints = {
        blob = "10.1.1.132"
        file = "10.1.1.133"
      }
    }
  }
}

variable "function_apps" {
  type = map(object({
    rg_name                     = optional(string)
    st_name                     = string
    python_version              = optional(string)
    dotnet_version              = optional(string)
    java_version                = optional(string)
    node_version                = optional(string)
    powershell_core_version     = optional(string)
    use_custom_runtime          = optional(string)
    use_dotnet_isolated_runtime = optional(string)
    pep_ip_address              = string
    app_settings                = optional(map(string))
    auth_settings_v2 = optional(object({
      auth_enabled                            = optional(bool)
      unauthenticated_action                  = optional(string)
      forward_proxy_convention                = optional(string)
      http_route_api_prefix                   = optional(string)
      require_authentication                  = optional(bool)
      require_https                           = optional(bool)
      runtime_version                         = optional(string)
      excluded_paths                          = optional(list(string))
      default_provider                        = optional(string)
      forward_proxy_custom_host_header_name   = optional(string)
      forward_proxy_custom_scheme_header_name = optional(string)
      client_secret_setting_name              = optional(string)
      allowed_applications                    = optional(list(string))
      allowed_groups                          = optional(list(string))
      allowed_identities                      = optional(list(string))
      client_id                               = string
      jwt_allowed_client_applications         = optional(list(string))
      jwt_allowed_groups                      = optional(list(string))
      login_parameters                        = optional(map(string))
      tenant_auth_endpoint                    = string
      www_authentication_disabled             = optional(bool)
      allowed_audiences                       = optional(list(string))
      token_refresh_extension_time            = optional(number)
      token_store_enabled                     = optional(bool)
      token_store_path                        = optional(string)
      allowed_external_redirect_urls          = optional(list(string))
      cookie_expiration_convention            = optional(string)
      cookie_expiration_time                  = optional(string)
      logout_endpoint                         = optional(string)
      nonce_expiration_time                   = optional(string)
      preserve_url_fragments_for_logins       = optional(bool)
      token_store_sas_setting_name            = optional(string)
      validate_nonce                          = optional(bool)
    }))
    slot = optional(object({
      name = string
      pep_ip_address              = string
    }))
  }))
  default = {
    "func-republik01" = {
      st_name        = "stfuncrepublik01"
      python_version = "3.11"
      pep_ip_address = "10.1.1.134"
      app_settings = {
        "APPLICATIONINSIGHTS_AUTHENTICATION_STRING" = "Authorization=AAD"
        "BUILD_FLAGS"                               = "UseExpressBuild"
        "ENABLE_ORYX_BUILD"                         = "true"
        "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"  = "@Microsoft.KeyVault(VaultName=kv-infra-abc-01;SecretName=MySecret)"
        "SCM_DO_BUILD_DURING_DEPLOYMENT"            = "1"
        "WEBSITE_AUTH_AAD_ALLOWED_TENANTS"          = "xyz"
        "XDG_CACHE_HOME"                            = "/tmp/.cache"
        #IF WEBSITE CONTENT SHOULD BE ON A SHARE USE SETTINGS BELOW:
        #vnetContentShareEnabled IS NOT AVAILABLE IN THIS PROVIDER
        # "WEBSITE_CONTENTOVERVNET" = 1
        # "WEBSITE_CONTENTSHARE"    = "func-code"
        # WEBSITE_CONTENTAZUREFILECONNECTIONSTRING = "xyz"
      }
      auth_settings_v2 = {
        auth_enabled                          = false
        unauthenticated_action                = "Return403"
        forward_proxy_convention              = "NoProxy"
        http_route_api_prefix                 = "/.auth"
        require_authentication                = true
        require_https                         = true
        runtime_version                       = "~1"
        excluded_paths                        = ["/api/health"]
        forward_proxy_custom_host_header_name = "X-Original-Host"
        client_secret_setting_name            = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
        allowed_applications                  = ["123456-abcdef-xyz"]
        client_id                             = "123456-abcdef-xyz"
        tenant_auth_endpoint                  = "https://sts.windows.net/{tenant_id}/v2.0"
        www_authentication_disabled           = false
        allowed_audiences                     = ["api://123456-abcdef-xyz"]
        token_store_enabled                   = true
      }
      slot = {
        name = "stage"
        pep_ip_address              = "10.1.1.135"
      }
    }
    "func-republik002" = {
      rg_name        = "rg-func-republik01"
      st_name        = "stfuncrepublik01"
      python_version = "3.11"
      pep_ip_address = "10.1.1.135"
      app_settings = {
        "APPLICATIONINSIGHTS_AUTHENTICATION_STRING" = "Authorization=AAD"
        "BUILD_FLAGS"                               = "UseExpressBuild"
        "ENABLE_ORYX_BUILD"                         = "true"
        "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"  = "@Microsoft.KeyVault(VaultName=kv-infra-abc-01;SecretName=MySecret)"
        "SCM_DO_BUILD_DURING_DEPLOYMENT"            = "1"
        "WEBSITE_AUTH_AAD_ALLOWED_TENANTS"          = "xyz"
        "XDG_CACHE_HOME"                            = "/tmp/.cache"
      }
    }
  }
}
