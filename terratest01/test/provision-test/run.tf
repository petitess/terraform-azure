locals {
  my_ip = "188.150.104.230"
}

module "azure_kv" {
  source = "../../terraform"
  sub_id = "123"
  prefix = "unitest"
  st_map = {
    "st01" = {
      name                          = "stmaunitest01"
      account_kind                  = "StorageV2"
      account_replication_type      = "LRS"
      access_tier                   = "Hot"
      public_network_access_enabled = true
      allowed_ips                   = [local.my_ip]
      containers                    = ["con12", "con34"]
      tables                        = ["t12", "t34"]
      private_endpoints = {
        # blob = "10.1.3.8"
        # file = "10.1.3.9"
      }
    }
  }
}

output "kv_public_access" {
  value = module.azure_kv.kv_public_access
}

output "st_map" {
  value = module.azure_kv.st_map
}
