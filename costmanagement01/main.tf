terraform {
  required_version = ">= 1.13.3"

  # backend "azurerm" {
  #   storage_account_name = "stterraform000001"
  #   container_name       = "opsgenie-terraform-1-azure"
  #   key                  = "terraform.tfstate"
  #   use_azuread_auth     = true
  # }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #version = "~= 3.80"  for production
      version = "~> 4.46.0"
    }
  }
}

provider "azurerm" {
  subscription_id = local.sub_id
  features {}
}

locals {
  location     = "swedencentral"
  sub_id       = "123-b6d8-431f-b2a6-123"
  now          = timestamp()
  time         = formatdate("hhmm", local.now)
  todaydate    = formatdate("YYYY-MM-DD", local.now)
  end          = timeadd(local.now, "172800h")
  enddate      = formatdate("YYYY-MM-DD", local.end)
  tomorrow     = timeadd(local.now, "24h")
  tomorrowdate = formatdate("YYYY-MM-DD", local.tomorrow)
}

resource "azurerm_resource_group" "st" {
  name     = "rg-stcostmanagment01"
  location = local.location
}

resource "azurerm_storage_account" "cost" {
  name                            = "stcostmanagment01"
  resource_group_name             = azurerm_resource_group.st.name
  location                        = local.location
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  account_kind                    = "StorageV2"
  access_tier                     = "Hot"
  allow_nested_items_to_be_public = true
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
}

resource "azurerm_storage_container" "cost" {
  name               = "cost"
  storage_account_id = azurerm_storage_account.cost.id
}

resource "azurerm_subscription_cost_management_export" "usage" {
  name                         = "export-usage"
  subscription_id              = "/subscriptions/${local.sub_id}"
  recurrence_type              = "Daily"
  recurrence_period_start_date = "${local.todaydate}T00:00:00Z"
  recurrence_period_end_date   = "${local.enddate}T00:00:00Z"
  file_format                  = "Csv"

  export_data_storage_location {
    container_id     = azurerm_storage_container.cost.id
    root_folder_path = "abc"
  }

  export_data_options {
    type       = "Usage"
    time_frame = "MonthToDate"
  }
  lifecycle {
    ignore_changes = [ recurrence_period_start_date, recurrence_period_end_date ]
  }
}

resource "azurerm_subscription_cost_management_export" "actual" {
  name                         = "export-actual"
  subscription_id              = "/subscriptions/${local.sub_id}"
  recurrence_type              = "Daily"
  recurrence_period_start_date = "${local.todaydate}T00:00:00Z"
  recurrence_period_end_date   = "${local.enddate}T00:00:00Z"
  file_format                  = "Csv"

  export_data_storage_location {
    container_id     = azurerm_storage_container.cost.id
    root_folder_path = "abc"
  }

  export_data_options {
    type       = "ActualCost"
    time_frame = "MonthToDate"
  }
  lifecycle {
    ignore_changes = [ recurrence_period_start_date, recurrence_period_end_date ]
  }
}

resource "azurerm_subscription_cost_management_export" "amortized" {
  name                         = "export-amortized"
  subscription_id              = "/subscriptions/${local.sub_id}"
  recurrence_type              = "Daily"
  recurrence_period_start_date = "${local.todaydate}T00:00:00Z"
  recurrence_period_end_date   = "${local.enddate}T00:00:00Z"
  file_format                  = "Csv"

  export_data_storage_location {
    container_id     = azurerm_storage_container.cost.id
    root_folder_path = "abc"
  }

  export_data_options {
    type       = "AmortizedCost"
    time_frame = "MonthToDate"
  }
  lifecycle {
    ignore_changes = [ recurrence_period_start_date, recurrence_period_end_date ]
  }
}
