resource "azurerm_dns_zone" "dns" {
    name = var.zonename
    resource_group_name = var.rgname
    tags = var.tags
}

resource "azurerm_dns_a_record" "a" {
    for_each = {
    for arecord in var.arecord : arecord.name => arecord
    }
    zone_name = azurerm_dns_zone.dns.name
    name = each.value.name
    tags = var.tags
    resource_group_name = var.rgname
    ttl = each.value.ttl
    records = each.value.records
}

resource "azurerm_dns_aaaa_record" "aaaa" {
    for_each = {
    for aaaa in var.aaaa : aaaa.name => aaaa
    }
    zone_name = azurerm_dns_zone.dns.name
    name = each.value.name
    tags = var.tags
    resource_group_name = var.rgname
    ttl = each.value.ttl
    records = each.value.records
}

resource "azurerm_dns_caa_record" "caa" {
    for_each = {
    for caa in var.caa : caa.name => caa
    }
    zone_name = azurerm_dns_zone.dns.name
    name = each.value.name
    tags = var.tags
    resource_group_name = var.rgname
    ttl = each.value.ttl
    dynamic "record" {
      for_each = each.value.record
      iterator = record
      content {
        flags = record.value.flags
        tag = record.value.tag
        value = record.value.value
      }
    }
}

resource "azurerm_dns_cname_record" "cname" {
    for_each = {
    for cname in var.cname : cname.name => cname
    }
    zone_name = azurerm_dns_zone.dns.name
    name = each.value.name
    tags = var.tags
    resource_group_name = var.rgname
    ttl = each.value.ttl
    record = each.value.record
}

resource "azurerm_dns_mx_record" "mx" {
  for_each = {
    for mx in var.mx : mx.name => mx
    }
    zone_name = azurerm_dns_zone.dns.name
    name = each.value.name
    tags = var.tags
    resource_group_name = var.rgname
    ttl = each.value.ttl
    dynamic "record" {
      for_each = each.value.record
      iterator = record
      content {
        preference = record.value.preference
        exchange = record.value.exchange
      }
    }   
}

resource "azurerm_dns_ns_record" "ns" {
  for_each = {
    for ns in var.ns : ns.name => ns
    }
    zone_name = azurerm_dns_zone.dns.name
    name = each.value.name
    tags = var.tags
    resource_group_name = var.rgname
    ttl = each.value.ttl
    records = each.value.record
}

resource "azurerm_dns_ptr_record" "ptr" {
  for_each = {
    for ptr in var.ptr : ptr.name => ptr
    }
    zone_name = azurerm_dns_zone.dns.name
    name = each.value.name
    tags = var.tags
    resource_group_name = var.rgname
    ttl = each.value.ttl
    records = each.value.record
}

resource "azurerm_dns_srv_record" "srv" {
  for_each = {
    for srv in var.srv : srv.name => srv
    }
    zone_name = azurerm_dns_zone.dns.name
    name = each.value.name
    tags = var.tags
    resource_group_name = var.rgname
    ttl = each.value.ttl
    dynamic "record" {
      for_each = each.value.record
      iterator = record
      content {
        port = record.value.port
        priority = record.value.priority
        target = record.value.target
        weight = record.value.weight
      }
    }
}

resource "azurerm_dns_txt_record" "txt" {
    for_each = {
      for txt in var.txt : txt.name => txt
      }
      zone_name = azurerm_dns_zone.dns.name
      name = each.value.name
      tags = var.tags
      resource_group_name = var.rgname
      ttl = each.value.ttl
      dynamic "record" {
      for_each = each.value.record
      iterator = record
      content {
        value = record.value.value
      }
      }
}