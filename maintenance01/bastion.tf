resource "azurerm_bastion_host" "bastion" {
  count               = var.BastionDeploy ? 1 : 0
  name                = "bas-${var.prefix}01"
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name
  tags                = azurerm_resource_group.infra.tags
  ip_configuration {
    name                 = "ipconfig01"
    subnet_id            = azurerm_subnet.subnets[var.subnets[2].name].id
    public_ip_address_id = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_public_ip" "pip" {
  count               = var.BastionDeploy ? 1 : 0
  name                = "bas-${var.prefix}-pip"
  location            = azurerm_resource_group.infra.location
  resource_group_name = azurerm_resource_group.infra.name
  tags                = azurerm_resource_group.infra.tags
  allocation_method   = "Static"
  sku                 = "Standard"
}
