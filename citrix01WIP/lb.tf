locals {
  adcpip = [
    "pip1",
    "pip2",
    "pip3"
  ]
}

# locals {
#   Rules = [
#     {
#       name                           = "rule-http-pip1"
#       backend_port                   = 80
#       frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
#       frontend_port                  = 80
#     },
#     {
#       name                           = "rule-http-pip2"
#       backend_port                   = 80
#       frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[1].name
#       frontend_port                  = 80
#     },
#     {
#       name                           = "rule-http-pip3"
#       backend_port                   = 80
#       frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[2].name
#       frontend_port                  = 80
#     },
#     {
#       name                           = "rule-https-pip1"
#       backend_port                   = 443
#       frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
#       frontend_port                  = 443
#     },
#     {
#       name                           = "rule-https-pip2"
#       backend_port                   = 443
#       frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[1].name
#       frontend_port                  = 443
#     },
#     {
#       name                           = "rule-https-pip3"
#       backend_port                   = 443
#       frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[2].name
#       frontend_port                  = 443
#     }
#   ]
# }

resource "azurerm_lb" "lb" {
  name                = "lb-${var.prefix}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.lb.name
  tags = merge(var.tags, {
    Application : "Citrix"
    Service : "ADC"
  })
  sku = "Standard"
  dynamic "frontend_ip_configuration" {
    for_each = local.adcpip
    iterator = pip
    content {
      name                 = "ipconfig${pip.key}"
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
  resource_group_name = azurerm_resource_group.lb.name
  tags                = var.tags
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_lb_rule" "rule" {
for_each = toset(local.adcpip)
  name = "rule-http-${each.key}"
  protocol = "Tcp"
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.lb.id
  ]
  backend_port = 80
  frontend_ip_configuration_name = "ipconfig${index(local.adcpip, each.value)}"
  frontend_port = 80
  loadbalancer_id = azurerm_lb.lb.id
  probe_id = azurerm_lb_probe.probe.id
  disable_outbound_snat = true
  enable_floating_ip = true
  enable_tcp_reset = false 
  load_distribution = "Default"
}

resource "azurerm_lb_rule" "rule2" {
for_each = toset(local.adcpip)
  name = "rule-https-${each.key}"
  protocol = "Tcp"
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.lb.id
  ]
  backend_port = 443
  frontend_ip_configuration_name = "ipconfig${index(local.adcpip, each.value)}"
  frontend_port = 443
  loadbalancer_id = azurerm_lb.lb.id
  probe_id = azurerm_lb_probe.probe.id
  disable_outbound_snat = true
  enable_floating_ip = true
  enable_tcp_reset = false 
  load_distribution = "Default"
}