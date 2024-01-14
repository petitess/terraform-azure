terraform {
  required_version = ">= 1.6.0"

  backend "azurerm" {
    storage_account_name = "stterraform000001"
    container_name       = "opsgenie-terraform-1-azure"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "~= 3.80"  for production
      version = "~> 3.86.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "xxx-1a10-483e-95aa-xxx"
  features {}
}

data "azurerm_subscription" "sub" {}

data "local_file" "run" {
  for_each = fileset(".", "runbooks/*.ps1")
  filename = each.value
}