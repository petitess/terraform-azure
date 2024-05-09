variable "env" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = map(string)
}

variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "service_principal" {
  type = map(string)
}

