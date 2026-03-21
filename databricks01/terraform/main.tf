data "azurerm_subscription" "sub" {}

resource "azurerm_resource_group" "rg" {
  name = "rg-${local.prefix}-01"
  location = local.location
  tags = local.tags
}

resource "azurerm_resource_group" "dns" {
  name = "rg-dns-${var.env}-01"
  location = local.location
  tags = local.tags
}

resource "azurerm_resource_group" "dbw" {
  name = "rg-dbw-${var.env}-01"
  location = local.location
  tags = local.tags
}

resource "azurerm_private_dns_zone" "dns" {
  count               = length(var.pdnsz)
  name                = var.pdnsz[count.index]
  resource_group_name = azurerm_resource_group.dns.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  count                 = length(var.pdnsz)
  name                  = "link-${count.index}"
  resource_group_name   = azurerm_resource_group.dns.name
  private_dns_zone_name = var.pdnsz[count.index]
  virtual_network_id    = azurerm_virtual_network.vnet.id
  depends_on = [ azurerm_private_dns_zone.dns ]
}

resource "azurerm_role_assignment" "rbac_dbw_kv" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = "c5e82d0b-9fb6-4da3-b6b0-b7cbd87cf7ec"
  //Found in Entra, AppId: 2ff814a6-3304-4ab8-85cb-cd0e6f879c1d
}


