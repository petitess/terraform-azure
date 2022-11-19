# terraform-azure
### Setup

1. Install Azure CLI
2. [Download terraform](https://developer.hashicorp.com/terraform/downloads)
3. Modify Environment Variables

[Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

[Hashicorp Terraform Plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)

```
az login
```
```
az account list
```
```
az account show
```
```
az account set --subscription="SUBSCRIPTION_ID"
```
----------
```
terraform -help
```
```
terraform init 
```
```
terraform validate
```
```
terraform plan
```
```
terraform apply -auto-approve
```
```
terraform workspace show
```
```
terraform destroy
```
```
terraform workspace show
```
```
terraform workspace list
```
```
terraform workspace new dev
```
```
terraform workspace select dev
```
----------------
```
ssh-keygen -m PEM -t rsa -b 4096 -C "azureuser@myserver" -f terraform-azure.pem 
```
## Content

| Name | Description | 
|--|--|
| vnet01 | Virtual Network with NSG
