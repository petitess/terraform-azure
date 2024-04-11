env             = "dev"
location        = "westeurope"
prefix          = "infra"
subscription_id = "xxx"
automation_account = {
  name    = "aa-infra-mgmt-dev-we-01"
  rg_name = "rg-infra-mgmt-dev-we-01"
}
tags = {
  Application = "Automation"
  Environment = "Development"
}
schedules_daily = { # Don't use 00:00 and 01:00
  1 = { hour = "02", minute = "00" }
}

schedules_mon_fri = { # Don't use 00:00 and 01:00
  1 = { hour = "05", minute = "00" }
  2 = { hour = "06", minute = "00" }
  3 = { hour = "18", minute = "00" }

}

schedules_weekly = { # Don't use 00:00 and 01:00
  1 = { hour = "02", minute = "00", days = ["Monday", "Friday"] }
  2 = { hour = "14", minute = "30", days = ["Tuesday"] }
}

link_schedule_to_runbook = {
  1 = { run = "run-BackupAdc01", sch = "sch-daily-02-00" }
}
