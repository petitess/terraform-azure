Connect-AzAccount -Identity

Set-AzContext "sub-prod-01"

$TagKey = "AutoShutdown"

$VMs = Get-AzVM | Where-Object { $_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq "GroupA" }

ForEach ($VM in $VMs) {
    Stop-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force -NoWait
    Write-Output $VM.Name
}

$VMs = Get-AzVM | Where-Object { $_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq "GroupB" }

ForEach ($VM in $VMs) {
    Stop-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force -NoWait
    Write-Output $VM.Name
}

$VMs = Get-AzVM | Where-Object { $_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq "GroupC" }

ForEach ($VM in $VMs) {
    Stop-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force -NoWait
    Write-Output $VM.Name
}

$VMs = Get-AzVM | Where-Object { $_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq "GroupD" }

ForEach ($VM in $VMs) {
    Stop-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force -NoWait
    Write-Output $VM.Name
}