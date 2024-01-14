Connect-AzAccount -Identity

Set-AzContext "sub-xxx-prod-01"

$TagKey = "AutoShutdown"
$TagValues = "GroupC"

$day = (Get-Date).DayOfWeek
$VMs = Get-AzVM | Where-Object { $_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq $TagValues }


if ($day -eq "Friday") {

    ForEach ($VM in $VMs | Select-Object -First 5) {
        Start-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -NoWait
        Write-Output $VM.Name
    }
}
else {
    ForEach ($VM in $VMs) {
        Start-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -NoWait
        Write-Output $VM.Name
    }
}