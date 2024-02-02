terraform {
  required_version = ">= 1.6.0"
}

locals {
  now          = timestamp()
  time         = formatdate("hhmm", local.now)
  todaydate    = formatdate("YYYY-MM-DD", local.now)
  tomorrow     = timeadd(local.now, "24h")
  tomorrowdate = formatdate("YYYY-MM-DD", local.tomorrow)
}

output "locals" {
  value = {
    "time" = local.time
    "01"   = "${var.schedules_daily[1].hour -1}${(var.schedules_daily[1].minute == "00" ? "55" : tonumber(var.schedules_daily[1].minute) - 5)}"
    "02"   = "${var.schedules_daily[2].hour -1}${(var.schedules_daily[2].minute == "00" ? "55" : tonumber(var.schedules_daily[2].minute) - 5)}"
    "03"   = "${var.schedules_daily[4].hour -1}${(var.schedules_daily[4].minute == "00" ? "55" : tonumber(var.schedules_daily[4].minute) - 5)}"
    "04"   = local.time >= "${var.schedules_daily[1].hour -1}${(var.schedules_daily[1].minute == "00" ? "55" : tonumber(var.schedules_daily[1].minute) - 5)}"
    "05"   = local.time >= "${var.schedules_daily[2].hour -1}${(var.schedules_daily[2].minute == "00" ? "55" : tonumber(var.schedules_daily[2].minute) - 5)}"
    "06"   = local.time >= "${var.schedules_daily[4].hour -1}${(var.schedules_daily[4].minute == "00" ? "55" : tonumber(var.schedules_daily[4].minute) - 5)}"
    "07" = local.time >= "${var.schedules_daily[1].hour -1}${(var.schedules_daily[1].minute == "00" ? "55" : tonumber(var.schedules_daily[1].minute) - 5)}" ? "${local.tomorrowdate}T${format("%02s", var.schedules_daily[1].hour - 1)}:${var.schedules_daily[1].minute}:00Z" : "${local.todaydate}T${format("%02s", var.schedules_daily[1].hour - 1)}:${var.schedules_daily[1].minute}:00Z"
    "08" = local.time >= "${var.schedules_daily[2].hour -1}${(var.schedules_daily[2].minute == "00" ? "55" : tonumber(var.schedules_daily[2].minute) - 5)}" ? "${local.tomorrowdate}T${format("%02s", var.schedules_daily[2].hour - 1)}:${var.schedules_daily[2].minute}:00Z" : "${local.todaydate}T${format("%02s", var.schedules_daily[2].hour - 1)}:${var.schedules_daily[2].minute}:00Z"
    "09" = local.time >= "${var.schedules_daily[4].hour -1}${(var.schedules_daily[4].minute == "00" ? "55" : tonumber(var.schedules_daily[4].minute) - 5)}" ? "${local.tomorrowdate}T${format("%02s", var.schedules_daily[4].hour - 1)}:${var.schedules_daily[4].minute}:00Z" : "${local.todaydate}T${format("%02s", var.schedules_daily[4].hour - 1)}:${var.schedules_daily[4].minute}:00Z"
    "10" = "${format("hour:%02s", var.schedules_daily[1].hour -1)}"
    "11" = "${format("hour:%02s", var.schedules_daily[2].hour -1)}"
    "12" = "${format("hour:%02s", var.schedules_daily[4].hour -1)}"
  }
}

output "target-groups-arn-alternatice" {
  value = { for k, v in var.schedules_daily : k => v }
}
