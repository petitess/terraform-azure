locals {
  now      = timestamp()
  time     = formatdate("HH:mm:ss", local.now)
  date     = formatdate("YYYY-MM-DD", local.now)
  thistime = formatdate("HH:mm:ss", "2025-01-02T23:12:01Z")
  thisdate = formatdate("YYYY-MM-DD", "2025-01-02T23:12:01Z")
}

output "now" {
  value = "${local.date}T${local.time}"
}

output "thistime" {
  value = "${local.thisdate}T${local.thistime}"
  #thistime = "2025-01-02T11:12:01"
}
