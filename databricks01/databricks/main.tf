data "azurerm_subscription" "sub" {}

data "azurerm_databricks_workspace" "dbw" {
  name                = local.dbw_name
  resource_group_name = "rg-dbw-${var.env}-01"
}

data "azurerm_key_vault" "kv" {
  name                = local.key_vault_name
  resource_group_name = "rg-${local.prefix}-01"
}

output "sub" {
  value = data.azurerm_subscription.sub.id
}
output "dbw" {
  value = data.azurerm_databricks_workspace.dbw.workspace_url
}

resource "databricks_secret_scope" "kv" {
  name = "keyvault"

  keyvault_metadata {
    resource_id = data.azurerm_key_vault.kv.id
    dns_name    = data.azurerm_key_vault.kv.vault_uri
  }
}

resource "databricks_workspace_file" "init" {
  for_each = fileset("init_scripts", "/*.sh")
  path     = "/terraform/${each.value}"
  source   = "${path.module}/init_scripts/${each.value}"
}

resource "databricks_notebook" "notebook" {
  content_base64 = base64encode(<<-EOT
    # created from ${abspath(path.module)}
    display(spark.range(10))
    EOT
  )
  path     = "/Shared/Demo"
  language = "PYTHON"
}

resource "databricks_cluster" "cluster" {
  cluster_name  = "cluster-01"
  spark_version = "12.2.x-scala2.12"
  node_type_id  = "Standard_DS3_v2"
  #num_workers   = 1
  runtime_engine          = "PHOTON"
  autotermination_minutes = 30
  autoscale {
    min_workers = 1
    max_workers = 10
  }
  enable_local_disk_encryption = true
  spark_env_vars = {
    PYPI_PW   = "{{secrets/${databricks_secret_scope.kv.name}/pypi-pw}}"
    PYPI_USER = "{{secrets/${databricks_secret_scope.kv.name}/pypi-user}}"
  }
  # dynamic "init_scripts" { ## Activate if you have a working script
  #   for_each = local.init_scripts
  #   content {
  #     workspace {
  #       destination = init_scripts.value
  #     }
  #   }
  # }
}



