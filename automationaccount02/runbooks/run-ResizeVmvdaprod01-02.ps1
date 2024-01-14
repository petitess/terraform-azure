Connect-AzAccount -Identity

Set-AzContext "sub-xxx-prod-01"

$VMsizeSmall = "Standard_D2ads_v5"
$VMsizeOrginal = "Standard_D8ads_v5" #(Get-AzVM -Name "vmmtdprod01").HardwareProfile.VmSize

$Time = Get-Date -Format "HH:mm:ss"
Write-Output $Time

if ($Time -gt "21:00:00") {
    $VMs = Get-AzVM -Status | Where-Object { $_.Name -match "vmvdaprod01" -or $_.Name -match "vmvdaprod02" }

    $VMs | ForEach-Object {
        $_.HardwareProfile.VmSize = $VMsizeSmall
        $INFO = Update-AzVM -VM $_ -ResourceGroupName $_.ResourceGroupName
        if ($INFO.IsSuccessStatusCode) {
            Write-Output "Updated size: $($_.Name) : $VMsizeSmall"
        }
        else {
            Write-Output "Did not update size"
        }
    }
}
else {

    $VMs = Get-AzVM -Status | Where-Object { $_.Name -match "vmvdaprod01" -or $_.Name -match "vmvdaprod02" }

    $VMs | ForEach-Object {
        $_.HardwareProfile.VmSize = $VMsizeOrginal
        $INFO = Update-AzVM -VM $_ -ResourceGroupName $_.ResourceGroupName
        if ($INFO.IsSuccessStatusCode) {
            Write-Output "Updated size: $($_.Name) : $VMsizeOrginal"
        }
        else {
            Write-Output "Did not update size"
        }
    }
    
}