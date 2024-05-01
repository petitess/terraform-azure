variable "prefix" {}
variable "env" {}
variable "location" {}
variable "tags" {}

variable "vnet" {}
variable "subnets" {}
variable "natgatewaysubnets" {}

variable "nsg" {}

variable "my_ip" {
  default = "111.111.111.111"
}

variable "pdnsz" {
  default = [
    "privatelink.database.windows.net",
    "privatelink.datafactory.azure.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.azuredatabricks.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.azuresynapse.net"
  ]
}

variable "orchestration_base_url" {
  type = string
}

variable "automation_base_url" {
  type = string
}