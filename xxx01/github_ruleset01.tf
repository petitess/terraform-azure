terraform {
  required_version = "~> 1.0"

  backend "azurerm" {
    container_name   = "tfstate-analytics-common-infra"
    key              = "github.terraform.tfstate"
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id[var.env]

  features {}
}

provider "azuread" {
  tenant_id = var.tenant_id
}

provider "github" {
  owner = var.github_org
}

variable "tenant_id" {
  type    = string
  default = "tenant_id"
}

variable "subscription_id" {
  type = map(string)
  default = {
    dev = "sub_id"
    uat = "sub_id"
    prd = "sub_id"
  }
}

variable "github_org" {
  type    = string
  default = "001-ABC-APPLICATIONS"
}

variable "github_repo" {
  type    = string
  default = "analytics-common-infra"
}

variable "service_principal" {
  type = map(string)
  default = {
    dev = "SP-analytics-dev-westeurope-backup-ga"
    uat = "SP-analyticsuat-prd-westeurope-backup-ga"
    prd = "SP-analytics-prd-westeurope-backup-ga"
  }
}

variable "secret_rotator_service_principal" {
  type = map(string)
  default = {
    dev = "SP-analytics-dev-westeurope-secretsrotator"
    uat = "SP-analyticsuat-prd-westeurope-secretsrotator"
    prd = "SP-analytics-prd-westeurope-secretsrotator"
  }
}

variable "env" {
  type = string
  validation {
    condition     = contains(["dev", "uat", "prd"], var.env)
    error_message = "Invalid input, options: \"dev\", \"uat\", \"prd\"."
  }
}

variable "tfstate" {
  type = map(string)
  default = {
    dev = "stabcsdevweucore"
    uat = "stabcuprdweucore"
    prd = "stabcsprdweucore"
  }
}

locals {
  github_vars = {
    "subscription_id_${var.env}"          = var.subscription_id[var.env]
    "tenant_id_${var.env}"                = var.tenant_id
    "client_id_${var.env}"                = data.azuread_application.app.client_id
    "tfstate_storage_${var.env}"          = var.tfstate[var.env]
    "secret_rotator_client_id_${var.env}" = data.azuread_application.app_secret_rotator.client_id
  }
  passwordstate_monitor_id = "1234"
  passwordstate_api_key    = ""
}

data "azurerm_subscription" "sub" {}

data "azuread_application" "app" {
  display_name = var.service_principal[var.env]
}

data "azuread_application" "app_secret_rotator" {
  display_name = var.secret_rotator_service_principal[var.env]
}

data "github_team" "sgds" {
  slug = "analytics"
}

data "github_repository" "repo" {
  full_name = "${var.github_org}/${var.github_repo}"
}

resource "azuread_application_federated_identity_credential" "credential" {
  for_each       = { env = "environment:${var.env}", branch = "ref:refs/heads/main", pr = "pull_request" }
  display_name   = "github-${each.key}"
  application_id = data.azuread_application.app.id
  audiences = [
    "api://AzureADTokenExchange"
  ]
  issuer  = "https://token.actions.githubusercontent.com"
  subject = "repo:${var.github_org}/${var.github_repo}:${each.value}"
}

resource "azuread_application_federated_identity_credential" "credential_secret_rotator" {
  for_each       = { env = "environment:${var.env}", branch = "ref:refs/heads/main", pr = "pull_request" }
  display_name   = "github-${each.key}"
  application_id = data.azuread_application.app_secret_rotator.id
  audiences = [
    "api://AzureADTokenExchange"
  ]
  issuer  = "https://token.actions.githubusercontent.com"
  subject = "repo:${var.github_org}/${var.github_repo}:${each.value}"
}

resource "github_repository_environment" "env" {
  environment = var.env
  repository  = var.github_repo
  reviewers {
    teams = [data.github_team.sgds.id]
  }
}

resource "github_actions_variable" "vars" {
  for_each      = local.github_vars
  repository    = var.github_repo
  variable_name = each.key
  value         = each.value
}

resource "github_actions_variable" "monitor" {
  count         = var.env == "dev" ? 1 : 0
  repository    = var.github_repo
  variable_name = "passwordstate_monitor_id"
  value         = local.passwordstate_monitor_id
}

resource "github_actions_secret" "monitor" {
  count           = var.env == "dev" ? 1 : 0
  secret_name     = "passwordstate_api_key"
  plaintext_value = local.passwordstate_api_key
  repository      = var.github_repo
  lifecycle {
    ignore_changes = [plaintext_value]
  }
}

resource "github_repository_ruleset" "default" {
  repository  = var.github_repo
  name        = "_main"
  target      = "branch"
  enforcement = "active"
  conditions {
    ref_name {
      include = [
        "refs/heads/_main"
      ]
      exclude = []
    }
  }
  rules {
    deletion         = true
    non_fast_forward = true
    pull_request {
      dismiss_stale_reviews_on_push     = true
      require_code_owner_review         = true
      require_last_push_approval        = true
      required_approving_review_count   = 1
      required_review_thread_resolution = true
    }
  }
}

output "github_vars" {
  value = { for key, value in local.github_vars : key => value }
}


# terraform init -backend-config="storage_account_name=stabcsdevweucore" -reconfigure
# terraform apply --auto-approve -var=env=dev
# terraform apply --auto-approve -var=env=dev
