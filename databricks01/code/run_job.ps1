$DatabricksHost = $env:DATABRICKS_HOST
$tokenM = az account get-access-token --query accessToken --output tsv
$tokenD = az account get-access-token --scope "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d/.default" --query accessToken --output tsv
$url = "https://$DatabricksHost/api/2.2/jobs/list"
$headers = @{
    'Authorization'                            = "Bearer $tokenD"
    'X-Databricks-Azure-SP-Management-Token'   = "$tokenM"
    'X-Databricks-Azure-Workspace-Resource-Id' = '/subscriptions/xyz/resourceGroups/xyz/providers/Microsoft.Databricks/workspaces/xyz'
    'Content-Type'                             = 'application/json'
}
                        
$resp = Invoke-RestMethod -Uri $url -Headers $headers -Method Get
"Jobs: $($resp.Count)"
$resp.jobs | ForEach-Object {
    Write-Output $_.settings.name
    if ($_.settings.name -eq "mount_file_system") {
        Write-Output "Found $($_.job_id)"
        $jobId = $_.job_id
        $urlRun = "https://$DatabricksHost/api/2.2/jobs/run-now"
        $data = @{'job_id' = "$jobId" } | ConvertTo-Json
        $respRun = Invoke-RestMethod -Uri $urlRun -Headers $headers -Method Post -Body $data
        Write-Output "Ran: $($respRun.run_id)"
    }
    else {
        Write-Output "mount_file_system not found"
    }
}