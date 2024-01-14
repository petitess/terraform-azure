Connect-AzAccount -Identity

Set-AzContext "sub-xxx-prod-01"

$Time = Get-Date -Format "HH:mm:ss"
$ApiNames = (Get-AzApplicationInsightsWebTest).Name
$ResourceGroupName = 'rg-appi-prod-01'

if ($Time -gt "17:00:00") {
    
    $Status = "False"
    $ResourceGroupName = 'rg-appi-prod-01'
    
    $allWebtests = Get-AzResource -ResourceGroupName $ResourceGroupName `
    | Where-Object -Property ResourceType -EQ "microsoft.insights/webtests"
    
    ForEach ($ApiName in $ApiNames) {
        $alertId = $allWebtests | Where-Object { $_.Name -like "$ApiName*" } `
        | Select-Object -ExpandProperty ResourceId
        $enabled = Get-AzResource -ResourceId $alertId
        $enabled.Properties.Enabled = $Status
        $enabled | Set-AzResource -Force
        Write-Output "Disabled: $ApiName"
    }
}
else {

    $Status = "True"
    $allWebtests = Get-AzResource -ResourceGroupName $ResourceGroupName `
    | Where-Object -Property ResourceType -EQ "microsoft.insights/webtests"

    ForEach ($ApiName in $ApiNames) {
        $alertId = $allWebtests | Where-Object { $_.Name -like "$ApiName*" } `
        | Select-Object -ExpandProperty ResourceId
        $enabled = Get-AzResource -ResourceId $alertId
        $enabled.Properties.Enabled = $Status
        $enabled | Set-AzResource -Force
        Write-Output "Enabled: $ApiName"
    }
     
}




