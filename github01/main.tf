locals {
  app_roles = {
    "Role One" : "role.one"
    "Role Two" : "role.two"
  }

  app_scopes = {
    "Scope One" : "scope.one"
  }

  github_vars = {
    subscription_id = var.subscription_id[var.env]
    tenant_id       = var.tenant_id
    client_id       = azuread_service_principal.app.client_id
  }
}

data "azurerm_subscription" "sub" {}

data "azuread_service_principal" "azure" {
  display_name = "Azure Graph"
}

data "github_repository" "repo" {
  full_name = "${var.github_org}/${var.github_repo}"
}

resource "azuread_application" "app" {
  display_name    = var.service_principal[var.env]
  identifier_uris = ["api://github"]

  dynamic "app_role" {
    for_each = local.app_roles
    content {
      allowed_member_types = ["User", "Application"]
      display_name         = app_role.key
      description          = app_role.key
      value                = app_role.value
      enabled              = true
      id                   = uuidv5("dns", app_role.value)
    }
  }

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2
    known_client_applications      = [data.azuread_service_principal.azure.client_id]

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

  required_resource_access {
    resource_app_id = data.azuread_service_principal.azure.client_id
    resource_access {
      id   = uuidv5("dns", local.app_roles["Role One"])
      type = "Role"
    }
  }
}

resource "azuread_application_pre_authorized" "graph" {
  application_id       = azuread_application.app.id
  authorized_client_id = data.azuread_service_principal.azure.client_id
  permission_ids       = [uuidv5("dns", local.app_scopes["Scope One"])]
}

resource "azuread_application_federated_identity_credential" "credential" {
  display_name   = "github"
  application_id = azuread_application.app.id
  audiences = [
    "api://AzureADTokenExchange"
  ]
  issuer  = "https://token.actions.githubusercontent.com"
  subject = "repo:${var.github_org}/${var.github_repo}:environment:${var.env}"
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
}

resource "github_repository_environment" "env" {
  environment = var.env
  repository  = var.github_repo
}

resource "github_actions_environment_variable" "vars" {
  for_each = {
    for key, value in local.github_vars : key => value
  }
  environment   = github_repository_environment.env.environment
  repository    = var.github_repo
  variable_name = each.key
  value         = each.value
}

resource "azurerm_role_assignment" "st_tfstate" {
  scope                = data.azurerm_subscription.sub.id
  principal_id         = azuread_service_principal.app.object_id
  role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "sp" {
  scope                = data.azurerm_subscription.sub.id
  principal_id         = azuread_service_principal.app.object_id
  role_definition_name = "Owner"
}

resource "github_branch_protection" "main" {
  repository_id                   = data.github_repository.repo.id
  pattern                         = "_main"
  enforce_admins                  = true
  require_conversation_resolution = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}

output "github_vars" {
  value = { for key, value in local.github_vars : key => value }
}

