locals {
  adf_name   = "adf-${var.prefix}-01"
  mpep_id_st = one([for mpep in jsondecode(data.azapi_resource_list.mpep_st.output).value : mpep.id if strcontains(mpep.properties.privateEndpoint.id, substr(azurerm_data_factory_managed_private_endpoint.mpep_st.name, 0, 40))])
  mpep_id_kv = one([for mpep in jsondecode(data.azapi_resource_list.mpep_kv.output).value : mpep.id if strcontains(mpep.properties.privateEndpoint.id, substr(azurerm_data_factory_managed_private_endpoint.mpep_kv.name, 0, 40))])
  global_parameters = [
    {
      name  = "ENVIRONMENT_NAME"
      type  = "String"
      value = var.env
    },
    {
      name  = "STORAGE_ACCOUNT_NAME"
      type  = "String"
      value = azurerm_storage_account.storage_account.name
    },
    {
      name  = "KEY_VAULT_NAME"
      type  = "String"
      value = azurerm_key_vault.keyvault.name
    },
    {
      name  = "ORCHESTRATION_BASE_URL"
      type  = "String"
      value = var.orchestration_base_url
    },
    {
      name  = "AUTOMATION_BASE_URL"
      type  = "String"
      value = var.automation_base_url
    }
  ]
}

data "azapi_resource_list" "mpep_st" {
  depends_on = [
    azurerm_data_factory_managed_private_endpoint.mpep_st
  ]
  parent_id = azurerm_storage_account.storage_account.id
  type      = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2023-01-01"
  response_export_values = [
    "value"
  ]
}

data "azapi_resource_list" "mpep_kv" {
  depends_on = [
    azurerm_data_factory_managed_private_endpoint.mpep_kv
  ]
  parent_id = azurerm_key_vault.keyvault.id
  type      = "Microsoft.KeyVault/vaults/privateEndpointConnections@2023-07-01"
  response_export_values = [
    "value"
  ]
}

resource "azurerm_data_factory" "datafactory" {
  name                = local.adf_name
  resource_group_name = azurerm_resource_group.adf.name
  location            = var.location

  managed_virtual_network_enabled = true
  public_network_enabled          = false

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  dynamic "global_parameter" {
    for_each = local.global_parameters
    content {
      name  = global_parameter.value.name
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }
}

resource "azurerm_private_endpoint" "adf_pep" {
  name                          = "pep-${local.adf_name}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.adf.name
  subnet_id                     = azurerm_subnet.subnets["snet-pep"].id
  custom_network_interface_name = "nic-${local.adf_name}"
  private_service_connection {
    name                           = "${local.adf_name}-privateserviceconnection"
    private_connection_resource_id = azurerm_data_factory.datafactory.id
    subresource_names              = ["dataFactory"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name = "privatelink-datafactory-azure-net"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.dns[index(var.pdnsz, "privatelink.datafactory.azure.net")].id
    ]
  }
}

resource "azurerm_data_factory_integration_runtime_azure" "auto_resolve_integration_runtime" {
  name                    = "AutoResolveIntegrationRuntime"
  data_factory_id         = azurerm_data_factory.datafactory.id
  location                = "AutoResolve"
  virtual_network_enabled = true
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "int_shir" {
  name            = "SHIR"
  data_factory_id = azurerm_data_factory.datafactory.id
}

resource "azurerm_data_factory_managed_private_endpoint" "mpep_st" {
  name               = "${azurerm_storage_account.storage_account.name}-managedpe"
  data_factory_id    = azurerm_data_factory.datafactory.id
  target_resource_id = azurerm_storage_account.storage_account.id
  subresource_name   = "blob"
  timeouts {
    create = "1h"
  }
}

resource "azapi_update_resource" "mpep_approve_st" {
  type        = "Microsoft.Storage/storageAccounts/privateEndpointConnections@2023-01-01"
  resource_id = local.mpep_id_st
  body = jsonencode(
    {
      properties = {
        privateLinkServiceConnectionState = {
          description = "Approved via Terraform - ${azurerm_storage_account.storage_account.name}"
          status      = "Approved"
        }
      }
    }
  )
}

resource "azurerm_data_factory_managed_private_endpoint" "mpep_kv" {
  name               = "${azurerm_key_vault.keyvault.name}-managedpe"
  data_factory_id    = azurerm_data_factory.datafactory.id
  target_resource_id = azurerm_key_vault.keyvault.id
  subresource_name   = "Vault"
  timeouts {
    create = "1h"
  }
}

resource "azapi_update_resource" "mpep_approve_kv" {
  type        = "Microsoft.KeyVault/vaults/privateEndpointConnections@2023-07-01"
  resource_id = local.mpep_id_kv
  body = jsonencode(
    {
      properties = {
        privateLinkServiceConnectionState = {
          description = "Approved via Terraform - ${azurerm_key_vault.keyvault.name}"
          status      = "Approved"
        }
      }
    }
  )
}

resource "azurerm_role_assignment" "rbac_adf_st" {
  scope                = azurerm_storage_account.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.datafactory.identity.0.principal_id
}

resource "azurerm_role_assignment" "rbac_adf_kv" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azurerm_data_factory.datafactory.identity.0.principal_id
}

resource "azurerm_role_assignment" "rbac_adf_dbw" {
  scope                = azurerm_databricks_workspace.dbw.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_data_factory.datafactory.identity.0.principal_id
}

resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "link_st" {
  name                     = "AzureDataLakeStorage"
  data_factory_id          = azurerm_data_factory.datafactory.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.auto_resolve_integration_runtime.name ##"air-${local.prefix}"
  url                      = azurerm_storage_account.storage_account.primary_dfs_endpoint
  use_managed_identity     = true
}

resource "azurerm_data_factory_linked_service_key_vault" "link_kv" {
  name                     = "KeyVault"
  data_factory_id          = azurerm_data_factory.datafactory.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.auto_resolve_integration_runtime.name ##"air-${local.prefix}"
  key_vault_id             = azurerm_key_vault.keyvault.id

}

resource "azurerm_data_factory_linked_service_synapse" "link_synw" {
  name                     = "AzureSynapseAnalytics"
  data_factory_id          = azurerm_data_factory.datafactory.id
  integration_runtime_name = azurerm_data_factory_integration_runtime_azure.auto_resolve_integration_runtime.name
  connection_string        = "Data Source=tcp:${"module.synw.workspace_endpoints.sql"},1433;Initial Catalog=${"module.synw.sql_pools[].sql_pool_name"}"
  #connection_string        = "Data Source=tcp:${module.synw.workspace_endpoints.sql},1433;Initial Catalog=${module.synw.sql_pools["01"].sql_pool_name}"
}

resource "azurerm_data_factory_linked_service_sql_server" "sql" {
  name                     = "SqlServerOnPrem"
  data_factory_id          = azurerm_data_factory.datafactory.id
  connection_string        = "Integrated Security=False;Data Source=https://server.net;Initial Catalog=db01;User ID=sqladmin"
  integration_runtime_name = "AutoResolveIntegrationRuntime"
  key_vault_password {
    linked_service_name = azurerm_data_factory_linked_service_key_vault.link_kv.name
    secret_name         = "sql-pass"
  }
}

resource "azurerm_data_factory_linked_service_azure_databricks" "link_dbw" {
  name                       = "Databricks"
  data_factory_id            = azurerm_data_factory.datafactory.id
  adb_domain                 = "https://${azurerm_databricks_workspace.dbw.workspace_url}"
  msi_work_space_resource_id = azurerm_databricks_workspace.dbw.id
  existing_cluster_id        = "databricks_cluster.cluster.id"
  integration_runtime_name   = azurerm_data_factory_integration_runtime_azure.auto_resolve_integration_runtime.name
}


resource "azurerm_data_factory_linked_custom_service" "file" {
  name            = "RemoteFileServer"
  data_factory_id = azurerm_data_factory.datafactory.id
  type            = "FileServer"
  integration_runtime {
    name = azurerm_data_factory_integration_runtime_self_hosted.int_shir.name
  }
  parameters = {
    "remote_username"           = ""
    remote_password_secret_name = ""
    base_path                   = ""
  }
  type_properties_json = jsonencode(
    {
      host   = "@{linkedService().base_path}"
      userId = "@{linkedService().remote_username}"
      password = {
        secretName = "@linkedService().remote_password_secret_name"
        store = {
          referenceName = azurerm_data_factory_linked_service_key_vault.link_kv.name
          type : "LinkedServiceReference"
        }
        type = "AzureKeyVaultSecret"
      }
    }
  )
}

resource "azurerm_data_factory_linked_custom_service" "rest" {
  name            = "RestServiceAnonymous"
  data_factory_id = azurerm_data_factory.datafactory.id
  type            = "RestService"
  integration_runtime {
    name = "AutoResolveIntegrationRuntime"
  }
  type_properties_json = jsonencode(
    {
      url                               = "https://google.com"
      authentication                    = "Anonymous"
      enableServerCertificateValidation = false
    }
  )
}
