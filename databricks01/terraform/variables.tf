variable "env" {
  type    = string
  default = "dev"
}
variable "subid" {
  type    = string
  default = "x-fe7e71802e2e"
}

variable "pdnsz" {
  default = [
    "privatelink.database.windows.net",
    "privatelink.blob.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.azuredatabricks.net"
  ]
}
