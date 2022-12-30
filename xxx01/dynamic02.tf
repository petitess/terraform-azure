resource "azurerm_virtual_network" "dynamic_block" {
  name                = "vnet-dynamicblock-example-centralus"
  resource_group_name = azurerm_resource_group.dynamic_block.name
  location            = azurerm_resource_group.dynamic_block.location
  address_space       = ["10.10.0.0/16"]

  dynamic "subnet" {
    for_each = var.subnets
    iterator = item   #optional
    content {
      name           = item.value.name
      address_prefix = item.value.address_prefix
    }
  }
}

variable "subnets" {
  description = "list of values to assign to subnets"
  type = list(object({
    name           = string
    address_prefix = string
  }))
}

subnets = [
  { name = "snet1", address_prefix = "10.10.1.0/24" },
  { name = "snet2", address_prefix = "10.10.2.0/24" },
  { name = "snet3", address_prefix = "10.10.3.0/24" },
  { name = "snet4", address_prefix = "10.10.4.0/24" }
]
