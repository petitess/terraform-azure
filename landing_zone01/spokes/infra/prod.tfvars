location = "swedencentral"
spoke    = "infra"
prefix   = "spoke-infra-prod"
tags = {
  Environment = "production"
  Application = "infra"
}

vnet_address_space = ["10.10.1.0/24"]

firewall = {
  prority = 105
  network_rule_collection = [
  ]
  application_rule_collection = [

  ]
}
