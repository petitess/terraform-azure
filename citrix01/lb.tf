locals {
  adcpip = [
    "pip1",
    "pip2",
    "pip3"
  ]
}

resource "azurerm_lb" "lb" {
  name                = "lb-adc-${var.env}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.avil["01"].name
  tags = merge(var.tags, {
    Application : "Citrix"
    Service : "ADC"
  })
  sku = "Standard"
  dynamic "frontend_ip_configuration" {
    for_each = local.adcpip
    iterator = pip
    content {
      name                 = "lb-ipconfig-${pip.value}"
      public_ip_address_id = azurerm_public_ip.pip[pip.value].id
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lb" {
  name            = "lb-adc-pool01"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name                = "lb-probe01"
  loadbalancer_id     = azurerm_lb.lb.id
  port                = 9000
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_public_ip" "pip" {
  for_each            = toset(local.adcpip)
  name                = "lb-${var.prefix}-01-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.avil["01"].name
  tags                = var.tags
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_lb_rule" "rule80" {
  for_each = toset(local.adcpip)
  name     = "lb-rule-http-${each.key}"
  protocol = "Tcp"
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.lb.id
  ]
  backend_port                   = 80
  frontend_ip_configuration_name = "lb-ipconfig-${each.value}"
  frontend_port                  = 80
  loadbalancer_id                = azurerm_lb.lb.id
  probe_id                       = azurerm_lb_probe.probe.id
  disable_outbound_snat          = true
  enable_floating_ip             = true
  enable_tcp_reset               = false
}

resource "azurerm_lb_rule" "rule443" {
  for_each = toset(local.adcpip)
  name     = "lb-rule-https-${each.key}"
  protocol = "Tcp"
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.lb.id
  ]
  backend_port                   = 443
  frontend_ip_configuration_name = "lb-ipconfig-${each.value}"
  frontend_port                  = 443
  loadbalancer_id                = azurerm_lb.lb.id
  probe_id                       = azurerm_lb_probe.probe.id
  disable_outbound_snat          = true
  enable_floating_ip             = true
  enable_tcp_reset               = false
  load_distribution              = "Default"
}
