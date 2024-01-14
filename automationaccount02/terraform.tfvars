env      = "dev"
location = "swedencentral"
prefix   = "sys"
tags = {
  Application = "Automation"
  Company     = "Company"
  Environment = "Development"
}
schedules_daily = {
  1 = { hour = "01", minute = "00" }
  2 = { hour = "15", minute = "00" }
  3 = { hour = "06", minute = "00" }
  4 = { hour = "07", minute = "30" }
}

schedules_mon_fri = {
  1  = { hour = "05", minute = "00" }
  2  = { hour = "06", minute = "00" }
  3  = { hour = "07", minute = "00" }
  4  = { hour = "07", minute = "30" }
  5  = { hour = "08", minute = "00" }
  6  = { hour = "10", minute = "00" }
  7  = { hour = "14", minute = "00" }
  8  = { hour = "16", minute = "00" }
  9  = { hour = "17", minute = "00" }
  10 = { hour = "18", minute = "00" }
  11 = { hour = "19", minute = "00" }
  12 = { hour = "20", minute = "00" }
  13 = { hour = "21", minute = "00" }
  14 = { hour = "22", minute = "00" }
  15 = { hour = "23", minute = "00" }
  16 = { hour = "23", minute = "30" }
}

schedules_weekly = {
  1 = { hour = "01", minute = "00", days = ["Monday", "Friday"] }
  2 = { hour = "14", minute = "30", days = ["Tuesday"] }
}

link_schedule_to_runbook = {
  1  = { run = "run-BackupAdc01", sch = "sch-daily-01-00" }
  2  = { run = "run-EnableDisableWebTest01", sch = "sch-mon-fri-06-00" }
  3  = { run = "run-EnableDisableWebTest01", sch = "sch-mon-fri-18-00" }
  4  = { run = "run-ITglueSynk01", sch = "sch-daily-06-00" }
  5  = { run = "run-ITglueSynk01", sch = "sch-daily-15-00" }
  6  = { run = "run-PublicHolidays01", sch = "sch-mon-fri-08-00" }
  7  = { run = "run-PublicHolidays01", sch = "sch-mon-fri-10-00" }
  8  = { run = "run-PublicHolidays01", sch = "sch-mon-fri-14-00" }
  9  = { run = "run-PublicHolidays01", sch = "sch-mon-fri-16-00" }
  10 = { run = "run-ResizeVmvdaprod01-02", sch = "sch-mon-fri-23-30" }
  11 = { run = "run-ResizeVmvdaprod01-02", sch = "sch-mon-fri-05-00" }
  12 = { run = "run-StartVm01", sch = "sch-mon-fri-06-00" }
  13 = { run = "run-StartVm02", sch = "sch-mon-fri-07-00" }
  14 = { run = "run-StartVm03", sch = "sch-mon-fri-07-30" }
  15 = { run = "run-StopVm01", sch = "sch-mon-fri-23-00" }
  16 = { run = "run-TryStopVm01", sch = "sch-mon-fri-17-00" }
  17 = { run = "run-TryStopVm01", sch = "sch-mon-fri-18-00" }
  18 = { run = "run-TryStopVm01", sch = "sch-mon-fri-19-00" }
  19 = { run = "run-TryStopVm01", sch = "sch-mon-fri-20-00" }
  20 = { run = "run-TryStopVm01", sch = "sch-mon-fri-21-00" }
  21 = { run = "run-TryStopVm01", sch = "sch-mon-fri-22-00" }
  22 = { run = "run-TryStopVm02", sch = "sch-mon-fri-17-00" }
  23 = { run = "run-TryStopVm02", sch = "sch-mon-fri-18-00" }
  24 = { run = "run-TryStopVm02", sch = "sch-mon-fri-19-00" }
  25 = { run = "run-TryStopVm02", sch = "sch-mon-fri-20-00" }
  26 = { run = "run-TryStopVm02", sch = "sch-mon-fri-21-00" }
  27 = { run = "run-TryStopVm02", sch = "sch-mon-fri-22-00" }
  28 = { run = "run-TryStopVm03", sch = "sch-mon-fri-17-00" }
  29 = { run = "run-TryStopVm03", sch = "sch-mon-fri-18-00" }
  30 = { run = "run-TryStopVm03", sch = "sch-mon-fri-19-00" }
  31 = { run = "run-TryStopVm03", sch = "sch-mon-fri-20-00" }
  32 = { run = "run-TryStopVm03", sch = "sch-mon-fri-21-00" }
  33 = { run = "run-TryStopVm03", sch = "sch-mon-fri-22-00" }
  34 = { run = "run-TryStopVm04", sch = "sch-mon-fri-17-00" }
  35 = { run = "run-TryStopVm04", sch = "sch-mon-fri-18-00" }
  36 = { run = "run-TryStopVm04", sch = "sch-mon-fri-19-00" }
  37 = { run = "run-TryStopVm04", sch = "sch-mon-fri-20-00" }
  38 = { run = "run-TryStopVm04", sch = "sch-mon-fri-21-00" }
  39 = { run = "run-TryStopVm04", sch = "sch-mon-fri-22-00" }
}
