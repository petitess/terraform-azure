variable "env" {
  type = string
}
variable "subid" {
  type = string
}

variable "location" {
  type = string
}

variable "tags" {
  type = object({
  })
}

variable "spoke" {
  type = string
}

variable "prefix" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "firewall" {

}
