Connect-AzAccount -Identity

Set-AzContext "sub-xxx-prod-01"

$TagKey = "AutoShutdown"
$TagValues = "GroupA"

$VMs = Get-AzVM -Status | Where-Object { $_.Tags.Keys -eq $TagKey -and $_.Tags.Values -eq $TagValues }

ForEach ($VM in $VMs) {

    if ($VM.PowerState -match "VM running") {
        $scriptCode = "if (((query user) -split '\n' -replace '\s\s+', ';' | convertfrom-csv -Delimiter ';').STATE -contains 'Active') {Write-Output 'ActiveUsers'}else {Write-Output 'ShutdownSystem'}"

        $I = Invoke-AzVMRunCommand -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -CommandId 'RunPowerShellScript' -ScriptString $scriptCode
        $output = $I.Value[0].Message

        if ($output -eq "ShutdownSystem") {

            Stop-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force -NoWait
            Write-Output "$($VM.Name) No active users on the system. Shutting down."
        }
        else {
            if ($output -eq "ActiveUsers") {
                Write-Output "$($VM.Name) Active users on the system"
            }
        }
    }
}