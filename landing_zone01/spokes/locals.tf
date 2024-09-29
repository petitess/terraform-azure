locals {
  hub_sub_id       = "x-fe7e71802e2e"
  vnet_hub_name    = "vnet-hub-prod-01"
  vnet_hub_rg_name = "rg-hub-prod-01"
  vnet_hub_id      = "/subscriptions/${local.hub_sub_id}/resourceGroups/${local.vnet_hub_rg_name}/providers/Microsoft.Network/virtualNetworks/${local.vnet_hub_name}"
  firewall_hub_id  = "/subscriptions/${local.hub_sub_id}/resourceGroups/${local.vnet_hub_rg_name}/providers/Microsoft.Network/firewallPolicies/afwp-hub-prod-01"
}
