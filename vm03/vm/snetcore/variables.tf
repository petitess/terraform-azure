variable "prefix" {}
variable "env" {}
variable "tags" {}
variable "app" {}
variable "location" {}
variable "snetcoreid" {}

variable "vms-snetcore" {
  type = map(object({
    name = string
    size = string
    osdisksize = string
    tags = object({
      Application = string
      Service = string
      UpdateManagement = string
    })
    image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
      })
    networkInterfaces = object({
      private_ip_address = string
    })
  }))
}


