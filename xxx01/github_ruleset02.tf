terraform {
  required_version = "~> 1.0"

  backend "azurerm" {
    container_name   = "tfstate-abcd-analytics-infra"
    key              = "github.terraform.tfstate"
    use_azuread_auth = true
  }

  required_providers {

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "azuread" {
  tenant_id = local.tenant_id
}

provider "github" {
  owner = local.github_org
}

variable "env" {
  type = string
  validation {
    condition     = contains(["dev", "uat", "prd"], var.env)
    error_message = "Invalid input, options: \"dev\", \"uat\", \"prd\"."
  }
}

locals {
  tenant_id  = "e339bd4b-2e3b-4035-a452-2112d502f2ff"
  github_org = "045-ABCD-APPLICATIONS"
  github_repo = {
    dev = "azure-application-abcd-analytics-dev-westeurope"
    uat = "azure-application-abcd-analyticsuat-prd-westeurope"
    prd = "azure-application-abcd-analytics-prd-westeurope"
  }

  rules = {
    dev = [
      {
        repo        = local.github_repo[var.env]
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
            require_last_push_approval        = true
            required_approving_review_count   = 1
            required_review_thread_resolution = true
          }
        ]
      },
      {
        repo        = local.github_repo[var.env]
        name        = "release_dont_delete"
        target      = "branch"
        enforcement = "active"
        include = [
          "refs/heads/release/**"
        ]
        deletion         = true
        non_fast_forward = false
        pull_request     = []
      },
      {
        repo        = local.github_repo[var.env]
        name        = "tag_dont_delete"
        target      = "tag"
        enforcement = "active"
        include = [
          "~ALL"
        ]
        deletion         = true
        non_fast_forward = false
        pull_request     = []
      }
    ]
    uat = [
      {
        repo        = local.github_repo[var.env]
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
            require_last_push_approval        = true
            required_approving_review_count   = 1
            required_review_thread_resolution = true
          }
        ]
      },
      {
        repo        = local.github_repo[var.env]
        name        = "release_dont_delete"
        target      = "branch"
        enforcement = "active"
        include = [
          "refs/heads/release/**"
        ]
        deletion         = true
        non_fast_forward = false
        pull_request     = []
      },
      {
        repo        = local.github_repo[var.env]
        name        = "tag_dont_delete"
        target      = "tag"
        enforcement = "active"
        include = [
          "~ALL"
        ]
        deletion         = true
        non_fast_forward = false
        pull_request     = []
      }
    ]
    prd = [
      {
        repo        = local.github_repo[var.env]
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
            require_last_push_approval        = true
            required_approving_review_count   = 1
            required_review_thread_resolution = true
          }
        ]
      },
      {
        repo        = local.github_repo[var.env]
        name        = "release_dont_delete"
        target      = "branch"
        enforcement = "active"
        include = [
          "refs/heads/release/**"
        ]
        deletion         = true
        non_fast_forward = false
        pull_request     = []
      },
      {
        repo        = local.github_repo[var.env]
        name        = "tag_dont_delete"
        target      = "tag"
        enforcement = "active"
        include = [
          "~ALL"
        ]
        deletion         = true
        non_fast_forward = false
        pull_request     = []
      }
    ]
  }
}

resource "github_repository_ruleset" "rules" {
  for_each = {
    for a, b in local.rules[var.env] : a => b
  }
  repository  = each.value.repo
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
  }
}
