# terraform-azure
## Setup

1. Install Azure CLI
2. https://chocolatey.org/install

Powershell:

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))`

`choco install terraform -y`

`choco install terraform --force -y`

`get-azcontext`

`choco install git`

[Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

[Hashicorp Terraform Plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)

----------
terraform -help

terraform init 

terraform validate

terraform plan

terraform apply

terraform workspace show

terraform destroy

terraform workspace show

terraform workspace list

terraform workspace new dev

terraform workspace select dev

https://registry.terraform.io/providers/hashicorp/azurerm/latest

terraform init

terraform plan

terraform apply
