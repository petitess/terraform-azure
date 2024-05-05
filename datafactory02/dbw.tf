locals {
  dbw_name = "dbw-${var.prefix}-01"
  dbw_peps = [
    "databricks_ui_api",
    "browser_authentication"
  ]
}

resource "azurerm_databricks_workspace" "dbw" {
  name                          = local.dbw_name
  resource_group_name           = azurerm_resource_group.dbw.name
  tags = var.tags
  location                      = var.location
  sku                           = "premium"
  managed_resource_group_name   = "${substr(azurerm_resource_group.dbw.name, 0, length(azurerm_resource_group.dbw.name) - 2)}managed-${substr(azurerm_resource_group.dbw.name, length(azurerm_resource_group.dbw.name) - 2, 2)}"
  public_network_access_enabled = true
  network_security_group_rules_required = "NoAzureDatabricksRules"
  custom_parameters {
    no_public_ip                                         = true
    virtual_network_id                                   = azurerm_virtual_network.vnet.id
    public_subnet_name                                   = azurerm_subnet.subnets["snet-dbw-public"].name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.nsg["nsg-snet-dbw-public"].id
    private_subnet_name                                  = azurerm_subnet.subnets["snet-dbw-private"].name
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.nsg["nsg-snet-dbw-private"].id
  }
}

resource "azurerm_private_endpoint" "dbw_pep" {
  for_each = {
    for pep in local.dbw_peps : pep => pep
  }

  name                          = "pep-${substr(local.dbw_name, 0, length(local.dbw_name) - 2)}${replace(each.value, "_", "-")}-${substr(local.dbw_name, length(local.dbw_name) - 2, 2)}"
  location                      = var.location
  tags                          = var.tags
  resource_group_name           = azurerm_resource_group.dbw.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${substr(local.dbw_name, 0, length(local.dbw_name) - 2)}${replace(each.value, "_", "-")}-${substr(local.dbw_name, length(local.dbw_name) - 2, 2)}"

  private_service_connection {
    name                           = "${local.dbw_name}-${replace(each.value, "_", "-")}"
    private_connection_resource_id = azurerm_databricks_workspace.dbw.id
    subresource_names              = [each.value]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "privatelink-azuredatabricks-net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(var.pdnsz, "privatelink.azuredatabricks.net")].id
    ]
  }
}

resource "azurerm_role_assignment" "rbac_dbw_kv" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "1fc0c7b1-4457-49b4-ac1e-5a7dc4205730" 
  //Found in Entra, AppId: 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d
}