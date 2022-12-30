#If it's a map:

  for_each = tomap({
    for k, v in local.buckets_and_folders : k => v
    if var.s3_create[1]
  })

#If it's a set:

  for_each = toset([
    for v in local.buckets_and_folders : v
    if var.s3_create[1]
  ])

    
    
variable "enable_thing" {
  type = bool
}

resource "example" "example" {
  for_each = {
    for k, v in var.something : k => v
    if var.enable_thing
  }
}
