Connect-AzAccount -Identity

Set-AzContext "sub-prod-01"

$TagKey = "AutoShutdown"
$TagValues = "GroupA"

$VMs = Get-AzVM | Where-Object { $_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq $TagValues }

ForEach ($VM in $VMs) {
    Start-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -NoWait
    Write-Output $VM.Name
}