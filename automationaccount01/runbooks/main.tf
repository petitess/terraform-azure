terraform {
  required_version = ">= 1.7.0"


  backend "azurerm" {
    #storage_account_name = "stinfraterraformdevwe01"
    container_name   = "terraform-runbooks"
    key              = "runbooks.tfstate"
    use_azuread_auth = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.86.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

data "azurerm_subscription" "sub" {}

data "local_file" "run" {
  for_each = fileset(".", "runbooks-${var.env}/*.ps1")
  filename = each.value
}
