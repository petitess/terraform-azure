locals {
    now = timestamp()
    time = formatdate("hhmm", local.now)
    todaydate = formatdate("YYYY-MM-DD", local.now)
    tomorrow = timeadd(local.now, "24h")
    tomorrowdate = formatdate("YYYY-MM-DD", local.tomorrow)
}

resource "azurerm_automation_account" "aa" {
    name = "aa-${var.prefix}01"
    location = var.location
    tags = var.tags
    resource_group_name = azurerm_resource_group.rginfra.name
    sku_name =  "Basic"
    identity {
      type = "SystemAssigned"
    }
}

resource "azurerm_role_assignment" "aarole" {
    principal_id = azurerm_automation_account.aa.identity[0].principal_id
    role_definition_name = "Contributor"
    scope = data.azurerm_subscription.sub.id
}

resource "azurerm_automation_runbook" "run01" {
    name = "run-stop01"
    location = var.location
    tags = var.tags
    resource_group_name = azurerm_resource_group.rginfra.name
    automation_account_name = azurerm_automation_account.aa.name
    log_progress = "true"
    log_verbose = "true"
    runbook_type = "PowerShell"
    content = data.local_file.run-stopvm.content
}

resource "azurerm_automation_runbook" "run02" {
    name = "run-start01"
    location = var.location
    tags = var.tags
    resource_group_name = azurerm_resource_group.rginfra.name
    automation_account_name = azurerm_automation_account.aa.name
    log_progress = "true"
    log_verbose = "true"
    runbook_type = "PowerShell"
    content = data.local_file.run-startvm.content
}

resource "azurerm_automation_schedule" "sch01" {
    name = "run-stop01"
    automation_account_name = azurerm_automation_account.aa.name
    resource_group_name = azurerm_resource_group.rginfra.name
    frequency = "Day"
    start_time = local.time >= "1955" ? "${local.tomorrowdate}T20:00:00Z" : "${local.todaydate}T20:00:00Z"
}

resource "azurerm_automation_schedule" "sch02" {
    name = "run-start01"
    automation_account_name = azurerm_automation_account.aa.name
    resource_group_name = azurerm_resource_group.rginfra.name
    frequency = "Day"
    start_time = local.time >= "0555" ? "${local.tomorrowdate}T06:00:00Z" : "${local.todaydate}T06:00:00Z"
}

resource "azurerm_automation_job_schedule" "job01" {
    automation_account_name = azurerm_automation_account.aa.name
    resource_group_name = azurerm_resource_group.rginfra.name
    runbook_name = azurerm_automation_runbook.run01.name
    schedule_name = azurerm_automation_schedule.sch01.name
}

resource "azurerm_automation_job_schedule" "job02" {
    automation_account_name = azurerm_automation_account.aa.name
    resource_group_name = azurerm_resource_group.rginfra.name
    runbook_name = azurerm_automation_runbook.run02.name
    schedule_name = azurerm_automation_schedule.sch02.name
}

output "locals" {
  value = {
    "now" = local.now,
    "todaydate" = local.todaydate
    "time" = local.time,
    "tomorrow" = local.tomorrow
    "tomorrowdate" = local.tomorrowdate
  }
}