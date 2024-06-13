resource "azurerm_data_protection_backup_vault" "vault" {
  name                       = "backup-${local.prefix}-01"
  resource_group_name        = module.rg["backup_vault"].resource_group_name
  location                   = var.context.location
  datastore_type             = "VaultStore"
  redundancy                 = "GeoRedundant"
  retention_duration_in_days = 14

  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azapi_resource" "policy" {
  type      = "Microsoft.DataProtection/BackupVaults/backupPolicies@2024-04-01"
  name      = "policy-blob-vaulted"
  parent_id = azurerm_data_protection_backup_vault.vault.id
  body = {

    properties = {
      objectType = "BackupPolicy"
      datasourceTypes = [
        "Microsoft.Storage/storageAccounts/blobServices"
      ]
      policyRules = [
        {
          isDefault  = true
          name       = "Default"
          objectType = "AzureRetentionRule"
          lifecycles = [
            {
              targetDataStoreCopySettings = []
              deleteAfter = {
                objectType = "AbsoluteDeleteOption"
                duration   = "P7D"
              }
              sourceDataStore = {
                dataStoreType = "VaultStore"
                objectType    = "DataStoreInfoBase"
              }
            }
          ]
        },
        {
          name       = "BackupDaily"
          objectType = "AzureBackupRule"
          backupParameters = {
            backupType = "Discrete"
            objectType = "AzureBackupParams"
          }
          dataStore = {
            dataStoreType = "VaultStore"
            objectType    = "DataStoreInfoBase"
          }
          trigger = {
            objectType = "ScheduleBasedTriggerContext"
            schedule = {
              timeZone = "UTC"
              repeatingTimeIntervals = [
                "R/2024-05-23T21:00:00+01:00/P1D"
              ]
            }
            taggingCriteria = [
              {
                isDefault       = true
                taggingPriority = 99
                tagInfo = {
                  tagName = "Default"
                }
              }
            ]
          }
        }
      ]
    }
  }
}

resource "azapi_resource" "st_tfstate_backup" {
  type      = "Microsoft.DataProtection/backupVaults/backupInstances@2024-04-01"
  name      = data.azurerm_storage_account.st_tfstate.name
  parent_id = azurerm_data_protection_backup_vault.vault.id
  body = {

    properties = {
      friendlyName = data.azurerm_storage_account.st_tfstate.name
      identityDetails = {
        useSystemAssignedIdentity = true
      }
      objectType = "BackupInstance"
      dataSourceInfo = {
        resourceID       = data.azurerm_storage_account.st_tfstate.id
        resourceLocation = var.context.location
        datasourceType   = "Microsoft.Storage/storageAccounts/blobServices"
        resourceName     = data.azurerm_storage_account.st_tfstate.name
        objectType       = "Datasource"
        resourceType     = "Microsoft.Storage/storageAccounts"
      }
      dataSourceSetInfo = {
        resourceID       = data.azurerm_storage_account.st_tfstate.id
        resourceLocation = var.context.location
        datasourceType   = "Microsoft.Storage/storageAccounts/blobServices"
        resourceName     = data.azurerm_storage_account.st_tfstate.name
        objectType       = "DatasourceSet"
        resourceType     = "Microsoft.Storage/storageAccounts"
      }
      policyInfo = {
        policyId = azapi_resource.policy.id
        policyParameters = {
          backupDatasourceParametersList = [
            {
              objectType = "BlobBackupDatasourceParameters"
              containersList = [
                "tfstate",
                "tfstate-sgds-analytics-dp",
                "tfstate-sgds-analytics-notebooks",
                "tfstate-sgds-analytics-dw"
              ]
            }
          ]
        }
      }
    }
  }
}
