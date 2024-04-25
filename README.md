## Terraform-azure
<details><summary>Setup</summary>
<p>

1. Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)
2. Download [terraform](https://developer.hashicorp.com/terraform/downloads)
3. Modify Environment Variables `rundll32 sysdm.cpl,EditEnvironmentVariables`
4. Install [Terraform Plugin for VS Code](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform)
5. Use [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs), [AzureAD Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs), [Azapi Provider](https://registry.terraform.io/providers/Azure/azapi/latest/docs)
</p>

</details>

```
az login --tenant ""
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
| alert01 | Service Health Alerts
| appserviceplan01 | Azure App Service Plan integrated with vnet
| appserviceplan02 | Google Tag Manager 
| automationaccount01 | Scheduled Runbooks 
| automationaccount02 | Runbooks from files + link schedules
| availabilityset01 | Multiple availability sets
| citrix01 | Citrix NetScaler(ADC) with high-availability(HA) 
| datafactory01 | Data factory, pipelines, datasets, linked services
| dns01 | Public DNS zone - array 
| keyvault01 | Create Secrets for VMs 
| loadbalancer01 | Internal load balancer
| loadbalancer02 | External load balancer
| maintenance01 | Update management center 
| privateendpoint01 | Storage Account: Blob, File, Queue, Table 
| storageaccount01 | Containers, Fileshares, Queues, Tables 
| storageaccount02 | Fileshare with backup 
| time01 | time function + leading zeros
| vm01 | A virtual machine with bastion
| vm02 | Deploy Multiple Virtual Machines
| vm03 | Virtual Machine Array 
| vmss01 | Virtual machine scale set with auto scaling 
| vnet01 | Virtual Network with NSG 10.0.0.0/16
| vnet02 | Virtual Network with NSG 10.10.0.0/16 (citrix)

