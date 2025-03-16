variable "env" {
  validation {
    condition     = var.env == "dev" || var.env == "prod"
    error_message = "must be dev or prod"
  }
}

variable "gh_pat" {
  description = "Classic token. Repo permission required"
}

locals {
  sp_name    = "sp-github-${var.env}"
  github_org = "petitess"
  github_repo = {
    dev  = "repo-dev"
    prod = "repo-prod"
  }

  fed_creds = {
    branch = "ref:refs/heads/main"
    env    = "environment:${var.env}"
    pr     = "pull_request"
  }

  repo = {
    name = "repo-dev"
    env = {
      "subscription_id_${var.env}" = "123abc"
      "tenant_id_${var.env}"       = "123abc"
      "client_id_${var.env}"       = azuread_application.app.client_id
      "tfstate_storage_${var.env}" = "sttfstateabc01"
    }
    rules = [
      {
        name        = "default"
        target      = "branch"
        enforcement = "active"
        include = [
          "refs/heads/main",
          "refs/heads/develop"
        ]
        deletion         = true
        non_fast_forward = true
        pull_request = [
          {
            dismiss_stale_reviews_on_push     = true
            require_code_owner_review         = true
            require_last_push_approval        = false
            required_approving_review_count   = 0
            required_review_thread_resolution = true
          }
        ]
        required_check = [[
          "build-and-test / build-and-test",
          "scan / sonar_generic"
        ]]
      },
      {
        name        = "release_dont_delete"
        target      = "branch"
        enforcement = "active"
        include = [
          "refs/heads/release/**"
        ]
        deletion         = true
        non_fast_forward = false
        pull_request     = []
        required_check   = []
      },
      {
        name        = "tag_dont_delete"
        target      = "tag"
        enforcement = "active"
        include = [
          "~ALL"
        ]
        deletion         = true
        non_fast_forward = false
        pull_request     = []
        required_check   = []
      }
    ]
  }
}

resource "azuread_application" "app" {
  display_name = local.sp_name
}

resource "azuread_service_principal" "app" {
  client_id = azuread_application.app.client_id
}

resource "azuread_application_federated_identity_credential" "app" {
  for_each       = local.fed_creds
  application_id = azuread_application.app.id
  display_name   = "github-${each.key}"
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:${local.github_org}/${local.github_repo[var.env]}:${each.value}"
  audiences      = ["api://AzureADTokenExchange"]
}

resource "azuread_application_federated_identity_credential" "app_feature" {
  count          = var.env == "dev" ? 5 : 0
  display_name   = "github-feature${count.index + 1}"
  application_id = azuread_application.app.id
  audiences = [
    "api://AzureADTokenExchange"
  ]
  issuer  = "https://token.actions.githubusercontent.com"
  subject = "repo:${local.github_org}/${local.repo.name}:ref:refs/heads/feature/feature0${count.index + 1}"
}

resource "github_repository" "repo" {
  name       = local.repo.name
  visibility = "public"

}

resource "github_actions_variable" "repo" {
  for_each      = local.repo.env
  repository    = github_repository.repo.id
  variable_name = each.key
  value         = each.value
}

resource "github_repository_environment" "repo" {
  repository          = github_repository.repo.id
  environment         = var.env
  can_admins_bypass   = true
  prevent_self_review = false
}

resource "github_actions_environment_variable" "repo" {
  repository    = github_repository.repo.id
  environment   = github_repository_environment.repo.environment
  variable_name = "my_env_var"
  value         = "12345"
}

resource "github_repository_ruleset" "rules" {
  for_each = {
    for a, b in local.repo.rules : a => b
    if var.env == "dev"
  }
  repository  = local.repo.name
  name        = each.value.name
  target      = each.value.target
  enforcement = each.value.enforcement
  conditions {
    ref_name {
      include = each.value.include
      exclude = []
    }
  }
  rules {
    deletion         = each.value.deletion
    non_fast_forward = each.value.non_fast_forward

    dynamic "pull_request" {
      for_each = each.value.pull_request
      content {
        dismiss_stale_reviews_on_push     = pull_request.value.dismiss_stale_reviews_on_push
        require_code_owner_review         = pull_request.value.require_code_owner_review
        require_last_push_approval        = pull_request.value.require_last_push_approval
        required_approving_review_count   = pull_request.value.required_approving_review_count
        required_review_thread_resolution = pull_request.value.required_review_thread_resolution
      }
    }
    dynamic "required_status_checks" {
      for_each = each.value.required_check
      content {
        dynamic "required_check" {
          for_each = required_status_checks.value
          content {
            context = required_check.value
          }
        }
      }
    }
  }
}
