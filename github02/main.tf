locals {
  prefix   = "abc-analytics-${var.env}-westeurope"
  stPrefix = "abc${var.env}weu"
}

data "azurerm_resource_group" "rg" {
  name                = "rg-infra-01"
}
