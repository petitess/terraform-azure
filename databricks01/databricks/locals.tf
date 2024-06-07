locals {
  location = "swedencentral"
  prefix   = "infra-${var.env}"
  tags = {
    Environment = var.env
    Application = "Infra"
  }
  my_ip     = "188.150.1.1"

  key_vault_name = "kv-sys-${local.prefix}-01"
  dbw_name       = "dbw-${local.prefix}-01"
  init_scripts = [
  "/terraform/pylibs-install.sh",
  "/terraform/msodbcsql17-install.sh"
]
}
