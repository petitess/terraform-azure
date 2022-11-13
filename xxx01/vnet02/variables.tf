variable "env" {
    description = "Environment"
    type = string
    default = "Test"
}

variable "app" {
    description = "Application"
    type = string
    default = "Infra"
}

variable "location" {
    description = "location"
    type = string
    default = "swedencentral"
}

variable "rg" {
    description = "Resource group name"
    type = string
    default = "rg-default"
}
