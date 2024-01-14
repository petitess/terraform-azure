Connect-AzAccount -Identity

Set-AzContext "sub-xxx-prod-01"

$TagKey = "Restart"

$VMs = Get-AzVM | Where-Object { $_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq "GroupA" }

ForEach ($VM in $VMs) {
    $INFO = Restart-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -NoWait
    Write-Output "$($INFO.StatusCode): $($VM.Name)"
}

$VMs = Get-AzVM | Where-Object { $_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq "GroupB" }

ForEach ($VM in $VMs) {
    $INFO = Restart-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -NoWait
    Write-Output "$($INFO.StatusCode): $($VM.Name)"  
}

