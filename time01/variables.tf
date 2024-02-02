variable "prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "tags" {
  type = map(string)
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