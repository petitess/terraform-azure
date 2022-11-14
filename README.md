# terraform-azure
### Setup

1. Install Azure CLI
2. [Download terraform](https://developer.hashicorp.com/terraform/downloads)
3. Modify Environment Variables

[Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

[Hashicorp Terraform Plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)

```powershell
choco install terraform -y
```
```powershell
choco install terraform --force -y
```
```powershell
choco install git
```


#### Azure CLI Login
```
az login
```
#### List Subscriptions
```
az account list
```
#### Show chosen subscription
```
az account show
```
#### Set Specific Subscription (if we have multiple subscriptions)
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
## Content

| Name | Description | 
|--|--|
| vnet01 | Virtual Network with NSG
