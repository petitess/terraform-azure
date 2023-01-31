locals {
  subnet = "snet-vda-test-01"
  ips = [
    "10.10.10.100",
    "10.10.10.101",
    "10.10.10.102"
  ]
}

resource "azurerm_lb" "lbi" {
  name                = "lbi-adc-${var.env}-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.avil["01"].name
  tags = merge(var.tags, {
    Application : "Citrix"
    Service : "ADC"
  })
  sku = "Standard"
  dynamic "frontend_ip_configuration" {
    for_each = local.ips
    iterator = ip
    content {
      name                          = "lbi-ipconfig-${index(local.ips, ip.value)}"
      subnet_id                     = azurerm_subnet.subnets[local.subnet].id
      private_ip_address_allocation = "Static"
      private_ip_address            = ip.value
    }
  }
}

resource "azurerm_lb_backend_address_pool" "lbi" {
  name            = "lbi-adc-pool01"
  loadbalancer_id = azurerm_lb.lbi.id
}

resource "azurerm_lb_probe" "probei" {
  name                = "lbi-probe01"
  loadbalancer_id     = azurerm_lb.lbi.id
  port                = 9000
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "rulei443" {
  for_each = toset(local.ips)
  name     = "lbi-rule-https-${index(local.ips, each.key)}"
  protocol = "Tcp"
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.lbi.id
  ]
  backend_port                   = 443
  frontend_ip_configuration_name = "lbi-ipconfig-${index(local.ips, each.key)}"
  frontend_port                  = 443
  loadbalancer_id                = azurerm_lb.lbi.id
  probe_id                       = azurerm_lb_probe.probei.id
  disable_outbound_snat          = true
  enable_floating_ip             = true
  enable_tcp_reset               = false
  load_distribution              = "Default"
}
