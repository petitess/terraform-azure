variable "prefix" {}
variable "env" {}
variable "tags" {}
variable "app" {}
variable "location" {}
variable "snetappid" {}

variable "vms-snetapp" {
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


