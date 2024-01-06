locals {
  now          = timestamp()
  time         = formatdate("hhmm", local.now)
  todaydate    = formatdate("YYYY-MM-DD", local.now)
  tomorrow     = timeadd(local.now, "24h")
  tomorrowdate = formatdate("YYYY-MM-DD", local.tomorrow)
}

resource "azurerm_automation_account" "aa" {
  name                = "aa-${var.prefix}-01"
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_automation_runbook" "run" {
  for_each                = data.local_file.run
  name                    = replace(replace(data.local_file.run[each.key].filename, "runbooks/", ""), ".ps1", "")
  location                = var.location
  tags                    = var.tags
  resource_group_name     = azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  log_progress            = "true"
  log_verbose             = "true"
  runbook_type            = "PowerShell"
  content                 = data.local_file.run[each.key].content
}

resource "azurerm_automation_schedule" "sch-daily" {
  for_each                = var.schedules_daily
  name                    = "sch-daily-${each.key}"
  automation_account_name = azurerm_automation_account.aa.name
  resource_group_name     = azurerm_resource_group.rg.name
  frequency               = "Day"
  start_time              = local.time >= replace(each.value, ":", "") - 5 ? "${local.tomorrowdate}T${each.value}:00Z" : "${local.todaydate}T${each.value}:00Z"
}

resource "azurerm_automation_schedule" "sch-mon-to-fri" {
  for_each                = var.schedules_mon_to_fri
  name                    = "sch-weekly-${each.key}"
  automation_account_name = azurerm_automation_account.aa.name
  resource_group_name     = azurerm_resource_group.rg.name
  frequency               = "Week"
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  start_time              = local.time >= replace(each.value, ":", "") - 5 ? "${local.tomorrowdate}T${each.value}:00Z" : "${local.todaydate}T${each.value}:00Z"
}

resource "azurerm_automation_job_schedule" "link" {
  for_each                = var.link_schedule_to_runbook
  automation_account_name = azurerm_automation_account.aa.name
  resource_group_name     = azurerm_resource_group.rg.name
  runbook_name            = each.key
  schedule_name           = each.value
  depends_on = [
    azurerm_automation_schedule.sch-daily,
    azurerm_automation_schedule.sch-mon-to-fri,
    azurerm_automation_runbook.run
  ]
}

output "locals" {
  value = {
    "now"          = local.now,
    "todaydate"    = local.todaydate
    "time"         = local.time,
    "tomorrow"     = local.tomorrow
    "tomorrowdate" = local.tomorrowdate
  }
}
