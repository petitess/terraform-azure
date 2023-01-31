frontend_ip_configuration_name = "ipconfig${index(local.adcpip, each.value)}"

locals {
  adcpip = [
    "pip1",
    "pip2",
    "pip3"
  ]
}
for_each            = toset(local.adcpip)
