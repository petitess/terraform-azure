variable "prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "automation_account" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}

variable "subscription_id" {
  type = string
}

variable "location" {
  type = string
}

variable "schedules_daily" {
  type = map(any)
}

variable "schedules_mon_fri" {
  type = map(any)
}

variable "schedules_weekly" {
  type = map(any)
}

variable "link_schedule_to_runbook" {
  type = map(any)
}
