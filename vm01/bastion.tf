# resource "azurerm_bastion_host" "bastion" {
#     name = "bas-${var.prefix}01"
#     location = azurerm_resource_group.rginfra.location
#     resource_group_name = azurerm_resource_group.rginfra.name
#     tags = azurerm_resource_group.rginfra.tags
#     ip_configuration {
#       name = "ipconfig01"
#       subnet_id = azurerm_subnet.subnets[var.subnets[2].name].id
#       public_ip_address_id = azurerm_public_ip.pip.id
#     }
# }

# resource "azurerm_public_ip" "pip" {
#   name = "bas-${var.prefix}-pip"
#   location = azurerm_resource_group.rginfra.location
#   resource_group_name = azurerm_resource_group.rginfra.name
#   tags = azurerm_resource_group.rginfra.tags
#   allocation_method = "Static"
#   sku = "Standard"
# }