locals {
  now          = timestamp()
  time         = formatdate("hhmm", local.now)
  todaydate    = formatdate("YYYY-MM-DD", local.now)
  tomorrow     = timeadd(local.now, "24h")
  tomorrowdate = formatdate("YYYY-MM-DD", local.tomorrow)
  summertime   = tonumber(formatdate("MM", local.now)) >= 04 && tonumber(formatdate("MM", local.now)) <= 10 ? 2 : 1
}

data "azurerm_resource_group" "aa" {
  name = var.automation_account.rg_name
}

data "azurerm_automation_account" "aa" {
  name                = var.automation_account.name
  resource_group_name = data.azurerm_resource_group.aa.name
}

resource "azurerm_automation_runbook" "run" {
  for_each                = data.local_file.run
  name                    = replace(replace(data.local_file.run[each.key].filename, "runbooks-${var.env}/", ""), ".ps1", "")
  location                = var.location
  tags                    = var.tags
  resource_group_name     = data.azurerm_resource_group.aa.name
  automation_account_name = data.azurerm_automation_account.aa.name
  log_progress            = "false"
  log_verbose             = "false"
  runbook_type            = "PowerShell72"
  content                 = data.local_file.run[each.key].content
  lifecycle {
    ignore_changes = [
      tags["CostCenter"],
      tags["Product"]
    ]
  }
}

resource "azurerm_automation_schedule" "sch-daily" {
  for_each                = var.schedules_daily
  name                    = "sch-daily-${each.value.hour}-${each.value.minute}"
  automation_account_name = data.azurerm_automation_account.aa.name
  resource_group_name     = data.azurerm_resource_group.aa.name
  timezone                = "Europe/Stockholm"
  frequency               = "Day"
  start_time              = local.time >= "${each.value.hour - local.summertime}${(each.value.minute == "00" ? "55" : tonumber(each.value.minute) - 5)}" ? "${local.tomorrowdate}T${format("%02s", each.value.hour - local.summertime)}:${each.value.minute}:00Z" : "${local.todaydate}T${format("%02s", each.value.hour - local.summertime)}:${each.value.minute}:00Z"
}

resource "azurerm_automation_schedule" "sch-mon-fri" {
  for_each                = var.schedules_mon_fri
  name                    = "sch-mon-fri-${each.value.hour}-${each.value.minute}"
  automation_account_name = data.azurerm_automation_account.aa.name
  resource_group_name     = data.azurerm_resource_group.aa.name
  timezone                = "Europe/Stockholm"
  frequency               = "Week"
  week_days               = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
  start_time              = local.time >= "${each.value.hour - local.summertime}${(each.value.minute == "00" ? "55" : tonumber(each.value.minute) - 5)}" ? "${local.tomorrowdate}T${format("%02s", each.value.hour - local.summertime)}:${each.value.minute}:00Z" : "${local.todaydate}T${format("%02s", each.value.hour - local.summertime)}:${each.value.minute}:00Z"
}

resource "azurerm_automation_schedule" "sch-weekly" {
  for_each                = var.schedules_weekly
  name                    = "sch-weekly-${each.value.hour}-${each.value.minute}"
  automation_account_name = data.azurerm_automation_account.aa.name
  resource_group_name     = data.azurerm_resource_group.aa.name
  timezone                = "Europe/Stockholm"
  frequency               = "Week"
  week_days               = each.value.days
  start_time              = local.time >= "${each.value.hour - local.summertime}${(each.value.minute == "00" ? "55" : tonumber(each.value.minute) - 5)}" ? "${local.tomorrowdate}T${format("%02s", each.value.hour - local.summertime)}:${each.value.minute}:00Z" : "${local.todaydate}T${format("%02s", each.value.hour - local.summertime)}:${each.value.minute}:00Z"
}

resource "azurerm_automation_job_schedule" "link" {
  for_each                = var.link_schedule_to_runbook
  automation_account_name = data.azurerm_automation_account.aa.name
  resource_group_name     = data.azurerm_resource_group.aa.name
  runbook_name            = each.value.run
  schedule_name           = each.value.sch
  depends_on = [
    azurerm_automation_schedule.sch-daily,
    azurerm_automation_schedule.sch-mon-fri,
    azurerm_automation_schedule.sch-weekly,
    azurerm_automation_runbook.run
  ]
}
