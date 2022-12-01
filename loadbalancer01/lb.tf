
locals {
  lbname = "lbi-${var.prefix}01"
  lbip = "10.0.7.250"
}

# resource "azurerm_public_ip" "lbpip" {
#   name = "${local.lbname}-pip01"
#   location = azurerm_resource_group.rginfra.location
#   resource_group_name = azurerm_resource_group.rginfra.name
#   tags = azurerm_resource_group.rginfra.tags
#   allocation_method = "Static"
#   sku = "Standard"
# }

resource "azurerm_lb" "lb" {
  name = local.lbname
  location = azurerm_resource_group.rginfra.location
  resource_group_name = azurerm_resource_group.rginfra.name
  tags = azurerm_resource_group.rginfra.tags
  sku = "Standard"
  frontend_ip_configuration {
    name = "ipconfig01"
    subnet_id = azurerm_subnet.app.id
    private_ip_address_allocation = "Static"
    private_ip_address = local.lbip
  }
}

resource "azurerm_lb_backend_address_pool" "backend" {
  name = "lb-pool01"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name = "lb-probe01"
  loadbalancer_id = azurerm_lb.lb.id
  port = 80
  protocol = "Tcp"
}

resource "azurerm_lb_rule" "rule" {
  name = "lb-rule01"
  protocol = "Tcp"
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.backend.id
  ]
  backend_port = 80
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  frontend_port = 80
  loadbalancer_id = azurerm_lb.lb.id
  probe_id = azurerm_lb_probe.probe.id
  disable_outbound_snat = true
}

# resource "azurerm_lb_outbound_rule" "out" {
#   name = "Internet"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
#   loadbalancer_id = azurerm_lb.lb.id
#   protocol = "All"
#   frontend_ip_configuration {
#     name = azurerm_lb.lb.frontend_ip_configuration[0].name
#   }
# }

resource "azurerm_network_interface_backend_address_pool_association" "vmweb" {
  network_interface_id = azurerm_network_interface.nicvmweb.id
  ip_configuration_name = azurerm_network_interface.nicvmweb.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
}
