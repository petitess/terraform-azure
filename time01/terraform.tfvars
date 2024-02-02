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
  2  = { hour = "06", minute = "30" }
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