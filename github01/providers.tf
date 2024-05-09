terraform {
  required_version = "~> 1.0"

  #   backend "azurerm" {
  #     storage_account_name = "st"
  #     container_name       = "tfstate"
  #     key                  = "github.terraform.tfstate"
  #     use_azuread_auth     = true
  #   }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
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
  token = "ghp_GipvpnNVHNVOwRtWHoxFNKiXpAQebu4OTeyk"
}
