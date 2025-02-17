variable "subid" {
  type      = string
  default   = "123-9118f13f6470"
  ephemeral = true
}
variable "location" {
  type    = string
  default = "swedencentral"

  validation {
    condition     = var.location == "swedencentral" || var.location == "westeurope"
    error_message = "Location: ${var.location} not allowed"
  }
}
variable "env" {
  type    = string
  default = "dev"
}
variable "affix" {
  type    = string
  default = "bim-dev"
}

variable "affixShort" {
  type    = string
  default = "bimdev"

  validation {
    condition     = length(var.affixShort) == 6
    error_message = "Variable 'affixShort' must be 6 characters long"
  }
}
