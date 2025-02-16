variable "subid" {
  type      = string
  default   = "123-9118f13f6470"
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

variable "st_list" {
  type = list(object({
    name                          = string
    rg_name                       = optional(string)
    account_kind                  = string
    account_replication_type      = string
    access_tier                   = string
    public_network_access_enabled = bool
    allowed_ips                   = list(string)
    containers                    = optional(list(string))
    shares                        = optional(list(string))
    queues                        = optional(list(string))
    tables                        = optional(list(string))
    private_endpoints = optional(object({
      blob  = optional(string)
      file  = optional(string)
      table = optional(string)
      queue = optional(string)
    }))
  }))

  default = [{
    name                          = "stlistrepublik01"
    account_kind                  = "StorageV2"
    account_replication_type      = "LRS"
    access_tier                   = "Hot"
    public_network_access_enabled = true
    allowed_ips                   = ["1.150.104.2"]
    containers                    = ["con12", "con34"]
    private_endpoints = {
      blob = "10.1.3.5"
      file = "10.1.3.6"
    }
    },
    {
      name                          = "stlistrepublik02"
      rg_name                       = "rg-stlistrepublik02"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      public_network_access_enabled = true
      allowed_ips                   = ["1.150.104.2"]
      containers                    = ["con12", "con34"]
      queues                        = ["queue01"]
      private_endpoints = {
        blob = "10.1.3.7"
      }
    },
    {
      name                          = "stlistrepublik03"
      rg_name                       = "rg-stlistrepublik02"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      public_network_access_enabled = true
      allowed_ips                   = ["1.150.104.2"]
      shares                        = ["share01"]
      tables                        = ["t12", "t34"]
  }]
}

variable "st_map" {
  type = map(object({
    name                          = string
    rg_name                       = optional(string)
    account_kind                  = string
    account_replication_type      = string
    access_tier                   = string
    public_network_access_enabled = bool
    allowed_ips                   = list(string)
    containers                    = optional(list(string))
    shares                        = optional(list(string))
    queues                        = optional(list(string))
    tables                        = optional(list(string))
    private_endpoints = optional(object({
      blob  = optional(string)
      file  = optional(string)
      table = optional(string)
      queue = optional(string)
    }))
  }))

  default = {
    "st01" = {
      name                          = "stmaprepublik01"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      public_network_access_enabled = true
      allowed_ips                   = ["1.150.104.2"]
      containers                    = ["con12", "con34"]
      tables                        = ["t12", "t34"]
      private_endpoints = {
        blob = "10.1.3.8"
        file = "10.1.3.9"
      }
    }
    "st02" = {
      name                          = "stmaprepublik02"
      rg_name                       = "rg-stmaprepublik02"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      public_network_access_enabled = true
      allowed_ips                   = ["1.150.104.2"]
      containers                    = ["con12", "con"]
      shares                        = ["share01"]
      private_endpoints = {
        blob = "10.1.3.10"
      }
    }
    "st03" = {
      name                          = "stmaprepublik03"
      rg_name                       = "rg-stmaprepublik02"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      public_network_access_enabled = true
      allowed_ips                   = ["1.150.104.2"]
      queues                        = ["queue01"]
    }
  }
}
