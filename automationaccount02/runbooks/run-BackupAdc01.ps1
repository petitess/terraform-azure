Connect-AzAccount -Identity

Set-AzContext "sub-xxx-prod-01"

$Now = Get-Date -Format "yyyyMMdd-HHmm"
$resourceGroupName = 'rg-vmadcprod01' 
$location = 'swedencentral' 
$snapshotResourceGroupName = "rg-backup-prod-01"


$vms = Get-AzVM `
-ResourceGroupName $resourceGroupName `
| Where-Object {$_.Name -match "vmadc"}

foreach ($vm in $vms) {
    $snapshot =  New-AzSnapshotConfig `
        -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id `
        -Location $location `
        -CreateOption copy
    New-AzSnapshot `
        -Snapshot $snapshot `
        -SnapshotName "snap-$($vm.name)-$Now" `
        -ResourceGroupName $snapshotResourceGroupName
}

$OldSnapshots = Get-AzSnapshot -ResourceGroupName $snapshotResourceGroupName | Where-Object {$_.TimeCreated -lt (Get-Date).AddDays(-6) -and $_.Name -match "vmadc"}
$OldSnapshots.Count
foreach ($OldSnapshot in $OldSnapshots) {
    Remove-AzSnapshot -ResourceGroupName $snapshotResourceGroupName -SnapshotName $OldSnapshot.Name -Force -Confirm:$false
}