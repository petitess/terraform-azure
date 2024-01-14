Connect-AzAccount -Identity

Set-AzContext "sub-xxx-prod-01"

$VmNames = @(
    'vmwebprod09'
    'vmwebprod12'
)

$VmNames | ForEach-Object {
    $VM = Get-AzVM | Where-Object Name -eq $_ 
    Restart-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name
    Write-output $("Restarted " + $VM.Name)
}