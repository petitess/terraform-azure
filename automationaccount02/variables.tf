variable "prefix" {
  type    = string
  default = "infra-test"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "test"
}

variable "tags" {
  description = "Tags"
  type = object({
    Environment = string
    Application = string
  })
  default = {
    Environment = "Test"
    Application = "Infra"
  }
}

variable "app" {
  description = "Application"
  type        = string
  default     = "Infra"
}

variable "location" {
  description = "location"
  type        = string
  default     = "swedencentral"
}

variable "schedules_daily" {
  type = map(any)
  default = {
    "1"     = "1:00"
    "20-30" = "20:30"
  }
}

variable "schedules_mon_to_fri" {
  type = map(any)
  default = {
    "4"     = "1:00"
    "18-30" = "20:30"
  }
}

variable "link_schedule_to_runbook" {
  type = map(any)
  default = {
    "run-StartVm01"   = "sch-daily-1"
    "run-StopVm01"    = "sch-weekly-4"
    "run-TryStopVm01" = "sch-daily-20-30"
  }
}
