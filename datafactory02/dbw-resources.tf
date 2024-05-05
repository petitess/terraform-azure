resource "databricks_secret_scope" "kv" {
  name = "keyvault"

  keyvault_metadata {
    resource_id = azurerm_key_vault.keyvault.id
    dns_name    = azurerm_key_vault.keyvault.vault_uri
  }
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
  enable_local_disk_encryption = false
  spark_env_vars = {
    PYPI_PW   = "{{secrets/${databricks_secret_scope.kv.name}/pypi-pw}}"
    PYPI_USER = "{{secrets/${databricks_secret_scope.kv.name}/pypi-user}}"
  }
  dynamic "init_scripts" {
    for_each = var.init_scripts
    content {
      workspace {
        destination = init_scripts.value
      }
    }
  }
}

resource "databricks_notebook" "script" {
  language = "PYTHON"
  path     = "/Shared/terraform/script01.py"
  source   = "${path.module}/script01.py"
}

resource "databricks_workspace_file" "init_01" {
  path = "/Shared/customer-notebook/init/pylibs-install.sh"
  source = "${path.module}/init_scripts/pylibs-install.sh"
}

resource "databricks_workspace_file" "init_02" {
  path = "/Shared/customer-notebook/init/msodbcsql17-install.sh"
  source = "${path.module}/init_scripts/msodbcsql17-install.sh"
}