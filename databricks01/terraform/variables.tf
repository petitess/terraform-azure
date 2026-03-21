variable "env" {
  type    = string
  default = "dev"
}
variable "subid" {
  type    = string
  default = "xyz"
}

variable "pdnsz" {
  default = [
    "privatelink.vaultcore.azure.net",
    "privatelink.azuredatabricks.net"
  ]
}
