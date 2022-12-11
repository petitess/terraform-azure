## Terraform-azure
<details><summary>Setup</summary>
<p>

1. Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)
2. [Download terraform](https://developer.hashicorp.com/terraform/downloads)
3. Modify Environment Variables
4. Install [Terraform Plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
5. Use [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
</p>

</details>

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
terraform apply -auto-approve
```
<details><summary>More terraform</summary>
<p>

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

</p>
</details>


----------------
<details><summary>Other</summary>
<p>

```
ssh-keygen -m PEM -t rsa -b 4096 -C "azureuser@myserver" -f terraform-azure.pem 
```
```
icacls.exe terraform-azure.pem /reset
```
```
icacls.exe terraform-azure.pem /grant:r "$($env:username):(r)"
```
```
icacls.exe terraform-azure.pem /inheritance:r
```
</p>
</details>

### Content

| Name | Description | 
|--|--|
| appserviceplan01 | Azure App Service Plan integrated with vnet
| appserviceplan02 | Google Tag Manager 
| keyvault01 | Create Secrets for VMs 
| loadbalancer01 | Internal load balancer
| loadbalancer02 | External load balancer
| vm01 | A virtual machine with bastion
| vm02 | Deploy Multiple Virtual Machines
| vm03 | Virtual Machine Array 
| vnet01 | Virtual Network with NSG

