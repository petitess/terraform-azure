resource "azurerm_maintenance_configuration" "updateA" {
  name                     = "update-${var.prefix}-01"
  location                 = var.location
  tags                     = var.tags
  resource_group_name      = azurerm_resource_group.infra.name
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  install_patches {
    reboot = "IfRequired"
    windows {
      classifications_to_include = [
        "Critical",
        "Security"
      ]
      kb_numbers_to_exclude = []
      kb_numbers_to_include = []
    }
  }

  window {
    duration             = "04:00"
    expiration_date_time = null
    recur_every          = "1Month Last Sunday" //"1Day"
    start_date_time      = "2023-10-15 23:15"
    time_zone            = "W. Europe Standard Time"
  }
}

resource "azurerm_maintenance_configuration" "updateB" {
  name                     = "update-${var.prefix}-02"
  location                 = var.location
  tags                     = var.tags
  resource_group_name      = azurerm_resource_group.infra.name
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  install_patches {
    reboot = "IfRequired"
    windows {
      classifications_to_include = [
        "Critical",
        "Security"
      ]
      kb_numbers_to_exclude = []
    }
  }

  window {
    duration             = "04:00"
    expiration_date_time = null
    recur_every          = "1Month Last Sunday" //"1Day"
    start_date_time      = "2023-10-15 23:15"
    time_zone            = "W. Europe Standard Time"
  }
}
