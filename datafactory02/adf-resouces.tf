resource "azapi_resource" "pipeline_parameters" {
  for_each                  = fileset("pipelines", "**/*.json")
  type                      = "Microsoft.DataFactory/factories/pipelines@2018-06-01"
  name                      = try(jsondecode(file("pipelines/${each.value}")).name, null)
  parent_id                 = azurerm_data_factory.datafactory.id
  schema_validation_enabled = false
  body = jsonencode(
    {
      properties = {
        activities  = try(jsondecode(file("pipelines/${each.value}")).properties.activities, null)
        annotations = try(jsondecode(file("pipelines/${each.value}")).properties.annotations, null)
        concurrency = try(jsondecode(file("pipelines/${each.value}")).properties.concurrency, null)
        description = try(jsondecode(file("pipelines/${each.value}")).properties.description, null)
        folder      = try(jsondecode(file("pipelines/${each.value}")).properties.folder, null)
        parameters  = try(jsondecode(file("pipelines/${each.value}")).properties.parameters, null)
        variables   = try(jsondecode(file("pipelines/${each.value}")).properties.variables, null)
      }
    }
  )
}

resource "azurerm_data_factory_custom_dataset" "dataset" {
  for_each = fileset("datasets", "**/*.json")
  name     = try(jsondecode(file("datasets/${each.value}")).name, null)
  linked_service {
    name       = try(jsondecode(file("datasets/${each.value}")).properties.linkedServiceName.referenceName, null)
    parameters = try({ for key, value in jsondecode(file("datasets/${each.value}")).properties.linkedServiceName.parameters : key => try(value.value, "") }, null)
  }
  description          = try(jsondecode(file("datasets/${each.value}")).properties.description, null)
  type_properties_json = try(jsonencode(jsondecode(file("datasets/${each.value}")).properties.typeProperties), null)
  type                 = try(jsondecode(file("datasets/${each.value}")).properties.type, null)
  data_factory_id      = azurerm_data_factory.datafactory.id
  parameters           = try({ for key, value in jsondecode(file("datasets/${each.value}")).properties.parameters : key => try(value.defaultValue, "") }, null)
  schema_json          = try(jsonencode(jsondecode(file("datasets/${each.value}")).properties.schema), null)
  annotations          = try(jsondecode(file("datasets/${each.value}")).properties.annotations, null)
  folder               = try(jsondecode(file("datasets/${each.value}")).properties.folder.name, null)
  depends_on = [
    azurerm_data_factory_linked_custom_service.file,
    azurerm_data_factory_linked_custom_service.rest,
    azurerm_data_factory_linked_service_azure_databricks.link_dbw,
    azurerm_data_factory_linked_service_data_lake_storage_gen2.link_st,
    azurerm_data_factory_linked_service_key_vault.link_kv,
    azurerm_data_factory_linked_service_sql_server.sql,
    azurerm_data_factory_linked_service_synapse.link_synw
  ]
}

resource "azurerm_data_factory_trigger_schedule" "sch" {
  for_each        = fileset("triggers", "**/*.json")
  name            = try(jsondecode(file("triggers/${each.value}")).name, null)
  data_factory_id = azurerm_data_factory.datafactory.id

  dynamic "pipeline" {
    for_each = try(jsondecode(file("triggers/${each.value}")).properties.pipelines, null)
    content {
      name       = pipeline.value.pipelineReference.referenceName
      parameters = pipeline.value.parameters
    }
  }
  annotations = try(jsondecode(file("triggers/${each.value}")).properties.annotations, null)
  description = try(jsondecode(file("triggers/${each.value}")).properties.description, null)
  interval    = try(jsondecode(file("triggers/${each.value}")).properties.typeProperties.recurrence.interval, null)
  frequency   = try(jsondecode(file("triggers/${each.value}")).properties.typeProperties.recurrence.frequency, null)
  start_time  = try(jsondecode(file("triggers/${each.value}")).properties.typeProperties.recurrence.startTime + "Z07:00", null)
  time_zone   = try(jsondecode(file("triggers/${each.value}")).properties.typeProperties.recurrence.timeZone, null)
  schedule {
    minutes = try(jsondecode(file("triggers/${each.value}")).properties.typeProperties.recurrence.schedule.minutes, null)
    hours   = try(jsondecode(file("triggers/${each.value}")).properties.typeProperties.recurrence.schedule.hours, null)
  }
  depends_on = [azapi_resource.pipeline_parameters]
}
