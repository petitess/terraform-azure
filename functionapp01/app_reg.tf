locals {
  app_scopes = {
    "Scope One" : "scope.one"
  }
}

resource "azuread_application" "app" {
  display_name    = "func-authorization-test-01"
  identifier_uris = ["api://func-authorization-test-01"]

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    dynamic "oauth2_permission_scope" {
      for_each = local.app_scopes
      content {
        enabled                    = true
        id                         = uuidv5("dns", oauth2_permission_scope.value)
        admin_consent_display_name = oauth2_permission_scope.key
        admin_consent_description  = oauth2_permission_scope.key
        value                      = oauth2_permission_scope.value
        user_consent_display_name  = oauth2_permission_scope.key
        user_consent_description   = oauth2_permission_scope.key
      }
    }
  }
}
