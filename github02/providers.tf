terraform {
  required_version = ">= 1.0"

  backend "azurerm" {
    container_name       = "tfstate-analytics"
    key                  = "github.terraform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.6.0"
    }
  }
}

provider "azuread" {

}

provider "github" {
  owner = local.github_org
  token = var.gh_pat
}
