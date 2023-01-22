variable "name" {}
variable "tags" {}
variable "rgname" {}
variable "location" {}
variable "replication" {}
variable "tier" {}

variable "kind" {}
variable "public_access" {}
variable "public_networks" {}
variable "versioning_enabled" {}

variable "containers" {}
variable "fileshares" {}
variable "queues" {}
variable "tables" {}
variable "peblob" {}
variable "pefile" {}
variable "pequeue" {}
variable "petable" {}
variable "pesubnet" {}
variable "vnetname" {}

data "azurerm_subscription" "sub" {}




