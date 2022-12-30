variable "prefix" {
  type = string
  default = "infra-test"
}

variable "env" {
    description = "Environment"
    type = string
    default = "test"
}

variable "tags" {
    description = "Tags"
    type = object({
        Environment = string
        Application = string
    })
    default = {
        Environment = "Test"
        Application = "Infra"
    }
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

variable "dns" {}