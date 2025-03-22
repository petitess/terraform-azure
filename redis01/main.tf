terraform {
  required_version = ">= 1.11.0"

  # backend "azurerm" {
  #   storage_account_name = "stabcdefault01"
  #   container_name       = "tfstate"
  #   key                  = "infra.terraform.tfstate"
  #   use_azuread_auth     = true
  # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.24.0"
    }
  }
}

provider "azurerm" {
  subscription_id     = var.subid
  storage_use_azuread = true

  features {}
}

data "azurerm_client_config" "current" {}

locals {
  pdnsz = [
    "privatelink.azure.com",
    "privatelink.redis.cache.windows.net"
  ]
}

resource "azurerm_private_dns_zone" "dns" {
  count               = length(local.pdnsz)
  name                = local.pdnsz[count.index]
  resource_group_name = azurerm_resource_group.hub.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns" {
  count                 = length(local.pdnsz)
  name                  = "${azurerm_virtual_network.vnet.name}-vnetlink"
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.dns[count.index].name
}

resource "azurerm_resource_group" "redis" {
  name     = "rg-redis-${var.env}-01"
  location = var.location
}

resource "azurerm_redis_cache" "redis" {
  name                = "redis-xyz-${var.env}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.redis.name

  sku_name = var.sku_config.name
  family   = var.sku_config.name == "Premium" ? "P" : "C"
  capacity = var.sku_config.capacity

  public_network_access_enabled = false
  non_ssl_port_enabled          = false
  minimum_tls_version           = "1.2"

  identity {
    type = "SystemAssigned"
  }

  redis_configuration {
    active_directory_authentication_enabled = true
    data_persistence_authentication_method  = null
    maxmemory_policy                        = var.redis_configuration.maxmemory_policy
    maxmemory_delta                         = var.sku_config.name == "Basic" ? 125 : var.redis_configuration.maxmemory_delta
    maxmemory_reserved                      = var.sku_config.name == "Basic" ? 125 : var.redis_configuration.maxmemory_reserved
    maxfragmentationmemory_reserved         = var.sku_config.name == "Basic" ? 125 : var.redis_configuration.maxfragmentationmemory_reserved
  }

  dynamic "patch_schedule" {
    for_each = var.patch_schedule != null ? [var.patch_schedule] : []
    content {
      day_of_week        = patch_schedule.value.day_of_week
      start_hour_utc     = patch_schedule.value.start_hour_utc
      maintenance_window = patch_schedule.value.maintenance_window
    }
  }
}

resource "azurerm_private_endpoint" "redis" {
  name                          = "pep-${azurerm_redis_cache.redis.name}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.redis.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${azurerm_redis_cache.redis.name}"

  private_service_connection {
    name                           = "conn-${azurerm_redis_cache.redis.name}"
    private_connection_resource_id = azurerm_redis_cache.redis.id
    subresource_names              = ["redisCache"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "privatelink.redis.cache.windows.net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(local.pdnsz, "privatelink.redis.cache.windows.net")].id
    ]
  }
}

resource "azurerm_redis_cache_access_policy_assignment" "redis" {
  for_each           = { for obj in var.access_policy_assignments : obj.name => obj }
  name               = each.value.name
  redis_cache_id     = azurerm_redis_cache.redis.id
  access_policy_name = each.value.access_policy_name
  object_id          = each.value.object_id
  object_id_alias    = each.value.object_id_alias
}
