variable "prefix" {
  type = string
}
variable "env" {
  type = string
}
variable "location" {
  type = string
}
variable "tags" {
  type = map(any)
}

variable "vnet" {
  type = object({
    name          = string
    address_space = list(string)
  })
}
variable "subnets" {
  type = list(object({
    name             = string
    address_prefixes = list(string)
    delegations      = list(string)
  }))
}
variable "natgatewaysubnets" {
  type    = list(string)
  default = []
}

variable "nsg" {
  type = any
}

variable "my_ip" {
  default = "111.111.111.111"
  type    = string
}

variable "pdnsz" {
  default = [
    "privatelink.database.windows.net",
    "privatelink.datafactory.azure.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.web.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.azuredatabricks.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.azuresynapse.net"
  ]
  type = list(string)
}

variable "orchestration_base_url" {
  type = string
}

variable "automation_base_url" {
  type = string
}

variable "subid" {
  type = string
}
variable "tenantid" {
  type = string
}

variable "init_scripts" {
  default = []
  type    = list(string)
}
