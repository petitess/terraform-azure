locals {
  env = "dev"

  service_principals = {
    dev = {
      sp-abc-01 = "x-bd30-e265df04f944"
      sp-abc-02 = "x-bf38-e13e7ff6d909"
      sp-abc-03 = "x-88f9-3f266548aa49"
      sp-abc-04 = ""
    }
  }

  roles = {
    dev = {
      kv = {
        id    = local.service_principals[local.env].sp-abc-01
        role  = "Key Vault Secrets User"
        scope = azurerm_resource_group.rg.id
      }
      st = {
        id    = local.service_principals[local.env].sp-abc-02
        role  = "Storage Blob Data Contributor"
        scope = azurerm_resource_group.rg.id
      }
      stSpBlob = {
        id    = local.service_principals[local.env].sp-abc-02
        role  = "Storage Blob Data Owner"
        scope = azurerm_resource_group.rg.id
      }
      stSpQueue = {
        id    = local.service_principals[local.env].sp-abc-04
        role  = "Storage Queue Data Contributor"
        scope = azurerm_resource_group.rg.id
      }
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-rabc-01"
  location = "swedencentral"
}

resource "azurerm_role_assignment" "rbac" {
  for_each = {
    for a, b in local.roles[local.env] : a => { id : b.id, scope : b.scope, role : b.role } if b.id != ""
  }
  principal_id         = each.value.id
  role_definition_name = each.value.role
  scope                = each.value.scope
}

output "rbac" {
  value = {
    for a, b in local.roles[local.env] : a => { id : b.id, scope : b.scope, role : b.role } if b.id != ""
  }
}
