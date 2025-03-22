variable "subid" {
  default = "123"
}

variable "env" {
  default = "dev"
}

variable "location" {
  default = "swedencentral"
}

variable "sku_config" {
  type = object({
    name     = string
    capacity = number
  })
  nullable    = false
  description = "Configuration for the Redis cache sku. The `sku_config` object is detailed below."
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_config.name)
    error_message = "The 'name' must be either 'Basic', 'Standard', or 'Premium'."
  }
  validation {
    condition     = var.sku_config.name == "Premium" ? contains([1, 2, 3, 4, 5], var.sku_config.capacity) : contains([0, 1, 2, 3, 4, 5, 6], var.sku_config.capacity)
    error_message = "Invalid sku capacity. For 'Premium' SKU, the capacity cannot be 0 or 6."
  }
  default = {
    name     = "Premium"
    capacity = 1
  }
}

variable "redis_configuration" {
  type = object({
    access_keys_authentication_enabled = optional(bool, null)
    maxmemory_policy                   = optional(string, "volatile-lru")
    maxmemory_delta                    = optional(number)
    maxmemory_reserved                 = optional(number)
    maxfragmentationmemory_reserved    = optional(number)
  })
  nullable    = true
  default     = {}
  description = "Configuration options for Redis. Includes settings for authentication, memory, backups, and persistence. The `redis_configuration` object is detailed below."
  validation {
    condition     = contains(["volatile-lru", "allkeys-lru", "volatile-random", "allkeys-random", "volatile-ttl", "noeviction", "volatile,lfu", "allkeys-lfu"], var.redis_configuration.maxmemory_policy)
    error_message = "The 'maxmemory_policy' must be either 'volatile-lru', 'allkeys-lru', 'volatile-random', 'allkeys-random', 'volatile-ttl', 'noeviction', 'volatile-lfu', or 'allkeys-lfu'."
  }
}


variable "access_policy_assignments" {
  type = list(object({
    name               = string
    access_policy_name = string
    object_id          = string
    object_id_alias    = string
  }))
  default = [
    # {
    #   access_policy_name = "Data Contributor"
    #   name               = "Data Contributor"
    #   object_id          = "123-531b450ec258"
    #   object_id_alias    = "Karol S"
    # }
  ]
  description = "Map of access policies to assign to the Redis Cache instance. The `access_policy_assignments` object is detailed below."
  validation {
    condition     = alltrue([for policy in var.access_policy_assignments : contains(["Data Reader", "Data Contributor", "Data Owner"], policy.access_policy_name)])
    error_message = "The 'access_policy_name' must be one of 'Data Reader', 'Data Contributor', or 'Data Owner'."
  }
}

variable "patch_schedule" {
  type = object({
    day_of_week        = string
    start_hour_utc     = optional(number, 0)
    maintenance_window = optional(string, "PT5H")
  })
  nullable = false
  default = {
    day_of_week        = "Sunday"
    start_hour_utc     = 0
    maintenance_window = "PT5H"
  }
  description = "Configuration for the patch schedule. The `patch_schedule` object is detailed below."
  validation {
    condition     = contains(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], var.patch_schedule.day_of_week)
    error_message = "The 'day_of_week' must be one of 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', or 'Sunday'."
  }
  validation {
    condition     = (var.patch_schedule.start_hour_utc >= 0 && var.patch_schedule.start_hour_utc <= 23)
    error_message = "The 'start_hour_utc' must be between 0 and 23."
  }
  validation {
    condition     = can(regex("^PT(5H|[6-9]H|\\d{2,}H|([5-9]\\d+M)|([1-9]\\d{2,}M))$", var.patch_schedule.maintenance_window))
    error_message = "The provided value for `maintenance_window` must be at least 5 hours (300 minutes) in ISO 8601 duration format. Examples: 'PT5H', 'PT300M'."
  }
}
