terraform {
  required_version = ">= 1.10.0"

  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
}
provider "http" {

}

variable "token" {
  description = "az account get-access-token --query accessToken --output tsv | Set-Clipboard"
  default     = ""
}

variable "subid" {
  default = "123-fe7e71802e2e"
}

data "http" "get" {
  url    = "https://management.azure.com/subscriptions/${var.subid}/resourceGroups/rg-infra-spoke-dev-we-01/providers/Microsoft.Network/networkSecurityGroups/nsg-snet-apim?api-version=2024-05-01"
  method = "GET"
  request_headers = {
    Authorization = "Bearer ${var.token}"
    Content-type  = "application/json"
  }
}

data "http" "put" {
  url    = "https://management.azure.com/subscriptions/${var.subid}/resourceGroups/rg-infra-spoke-dev-we-01/providers/Microsoft.Network/networkSecurityGroups/nsg-snet-apim/securityRules/nsgsr-terraform?api-version=2024-05-01"
  method = "POST"
  request_headers = {
    Authorization = "Bearer ${var.token}"
    Content-type  = "application/json"
  }
  request_body = jsonencode({
    properties = {
      access                   = "Allow"
      destinationAddressPrefix = "*"
      # destinationAddressPrefixes = []
      destinationPortRange = "443"
      # destinationPortRanges      = []
      direction           = "Inbound"
      priority            = 305
      protocol            = "TCP"
      sourceAddressPrefix = "Internet"
      # sourceAddressPrefixes      = []
      sourcePortRange = "*"
      # sourcePortRanges           = []
    }
  })
}

output "http_get" {
  value = {
    name        = jsondecode(data.http.get.response_body).name
    location    = jsondecode(data.http.get.response_body).location
    status_code = data.http.get.status_code
    method      = data.http.get.method
  }
}

output "http_put" {
  value = {
    # name        = jsondecode(data.http.put.response_body).name
    description = jsondecode(data.http.put.response_body) //.properties.description
    status_code = data.http.put.status_code
    method      = data.http.put.method
  }
}
