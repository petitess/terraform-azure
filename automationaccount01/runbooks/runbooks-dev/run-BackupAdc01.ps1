Connect-AzAccount -Identity

Set-AzContext "sub-infra-dev-01"

$vms = Get-AzVM `
    -ResourceGroupName $resourceGroupName `
| Where-Object { $_.Name -match "vm" }

$vms