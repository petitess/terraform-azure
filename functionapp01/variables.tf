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
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.azurewebsites.net",
    "privatelink.vaultcore.azure.net"
  ]
}
