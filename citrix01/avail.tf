resource "azurerm_resource_group" "avil" {
  for_each = var.availabilitysets
  name     = "rg-${each.value.name}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_availability_set" "avail" {
  for_each                     = var.availabilitysets
  name                         = "avail-${each.value.name}"
  location                     = var.location
  tags                         = var.tags
  resource_group_name          = azurerm_resource_group.avil[each.key].name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 20
}
