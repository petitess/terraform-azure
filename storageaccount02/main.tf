terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "~= 3.30"  for production
      version = ">= 3.30"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.2.0"
    }
  }
}

provider "azurerm" {
  features {}
}
provider "azapi" {}

data "azurerm_subscription" "sub" {}

resource "azurerm_resource_group" "infra" {
  name     = "rg-${var.prefix}-01"
  location = var.location
  tags     = var.tags
}

module "st" {
  for_each           = var.st
  source             = "./st"
  fileshares         = each.value.fileshares
  containers         = each.value.containers
  kind               = each.value.kind
  location           = var.location
  name               = each.value.name
  public_access      = each.value.public_access
  public_networks    = each.value.public_networks
  queues             = each.value.queues
  replication        = each.value.replication
  rgname             = azurerm_resource_group.infra.name
  rsvid              = azurerm_recovery_services_vault.rsv.id
  rsvname            = azurerm_recovery_services_vault.rsv.name
  rsvpolicyid        = azurerm_backup_policy_file_share.file.id
  tables             = each.value.tables
  tags               = var.tags
  tier               = each.value.tier
  versioning_enabled = each.value.versioning_enabled

}
