variable "env" {
  default = "dev"
}

variable "sub_id" {
  default = "123"
}
variable "prefix" {
  default = "boooom"
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
      allowed_ips                   = ["1.218.79.1"]
      containers                    = ["con12", "con34"]
      tables                        = ["t12", "t34"]
      private_endpoints = {
        # blob = "10.1.3.8"
        # file = "10.1.3.9"
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
        # blob = "10.1.3.10"
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
