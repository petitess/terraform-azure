locals {
  locations = {
    we = "WestEurope"
    ne = "NorthEurope"
  }

  apps = {
    app_we = {
      name      = "app-xyz-we-0001"
      locagtion = local.locations.we
      asp_id    = module.asp_avm_we.resource_id
    }
    app_ne = {
      name      = "app-xyz-ne-0001"
      locagtion = local.locations.ne
      asp_id    = module.asp_avm_ne.resource_id
    }
  }
}

resource "azurerm_resource_group" "app" {
  name     = "rg-app-${var.env}-01"
  location = local.locations.we
}

module "asp_avm_we" {
  source                 = "Azure/avm-res-web-serverfarm/azurerm"
  version                = "0.4.0"
  name                   = "asp-we-${var.env}-01"
  location               = local.locations.we
  resource_group_name    = azurerm_resource_group.app.name
  os_type                = "Linux"
  zone_balancing_enabled = false
  sku_name               = "P1v2"
  worker_count           = 1
}

module "asp_avm_ne" {
  source                 = "Azure/avm-res-web-serverfarm/azurerm"
  version                = "0.4.0"
  name                   = "asp-ne-${var.env}-01"
  location               = local.locations.ne
  resource_group_name    = azurerm_resource_group.app.name
  os_type                = "Linux"
  zone_balancing_enabled = false
  sku_name               = "P1v2"
  worker_count           = 1
}

module "app_avm" {
  for_each                 = local.apps
  source                   = "Azure/avm-res-web-site/azurerm"
  version                  = "0.14.2"
  name                     = each.value.name
  location                 = each.value.locagtion
  service_plan_resource_id = each.value.asp_id
  resource_group_name      = azurerm_resource_group.app.name
  os_type                  = "Linux"
  kind                     = "webapp"
}
