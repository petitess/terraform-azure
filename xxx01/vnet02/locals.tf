locals {
  Environment = lower(var.env)
  Application = lower(var.app)
  prefix = lower("${var.app}-${var.env}")
  env = lower(var.env)
  tags = {
    Environment = var.env
    Application = var.app
  }
}