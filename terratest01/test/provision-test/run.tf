
module "azure_kv" {
  source = "../../terraform"
  prefix = "unitest"
}

output "kv_public_access" {
  value = module.azure_kv.kv_public_access
}