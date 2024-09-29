location = "swedencentral"
spoke    = "infra"
prefix   = "spoke-infra-dev"
tags = {
  Environment = "development"
  Application = "infra"
}

vnet_address_space = ["10.10.0.0/24"]

firewall = {
  prority = 105
  network_rule_collection = [
    {
      action                = "Allow"
      collection_name       = "network"
      priority              = 100
      rule_name             = "allow-spoke"
      protocols             = ["Any"]
      source_addresses      = ["10.10.1.0/24"]
      source_ip_groups      = []
      destination_addresses = ["10.10.1.0/24"]
      destination_ports     = ["*"]
    }
  ]
  application_rule_collection = [
    {
      action                = "Allow"
      collection_name       = "application"
      priority              = 200
      rule_name             = "allow-google"
      destination_fqdns     = ["*.google.com"]
      destination_addresses = []
      destination_fqdn_tags = []
      destination_urls      = []
      source_addresses      = ["10.10.1.0/24"]
      source_ip_groups      = []
      terminate_tls         = false
      web_categories        = []
      protocol_type         = "Https"
      protocol_port         = 443

    }
  ]
}
