# Local PowerShell script: fetch GitHub repo contents and upload to Azure Databricks Workspace
# No Azure Functions involved

$ErrorActionPreference = "Stop"

# -----------------------------
# Configuration
# -----------------------------
$RepoOwner = "petitess"
$RepoName = "python"
$Branch = "main"
$GitHubToken = $env:github_token   # optional for public repos
$env:DATABRICKS_TOKEN = az account get-access-token --scope "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d/.default" --query accessToken --output tsv
$DatabricksHost = $env:DATABRICKS_HOST   # e.g. "https://adb-7405615244523266.6.azuredatabricks.net"
$DatabricksToken = $env:DATABRICKS_TOKEN # or PAT token "xdapi2b350a92c206ad8130"     

if (-not $DatabricksHost -or -not $DatabricksToken) {
    throw "DATABRICKS_HOST and DATABRICKS_TOKEN environment variables must be set"
}

$WorkspaceRoot = "/Shared"
$TempDir = ".\code\_repo_tmp"
$ZipPath = ".\code\repo.zip"

# -----------------------------
# Helpers
# -----------------------------
function Invoke-DatabricksApi {
    param (
        [string]$Method,
        [string]$Path,
        [object]$Body = $null
    )

    $headers = @{
        Authorization = "Bearer $DatabricksToken"
    }

    $uri = "$DatabricksHost/api/2.0/$Path"

    if ($Body) {
        Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -ContentType "application/json" -Body ($Body | ConvertTo-Json -Depth 10)
    }
    else {
        Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
    }
}

function Remove-DatabricksWorkspaceItem {
    param (
        [string]$Path
    )

    $items = Invoke-DatabricksApi -Method GET -Path "workspace/list?path=$Path"

    foreach ($item in $items.objects) {
        if ($item.object_type -eq "DIRECTORY") {
            # Recursively delete directory contents first
            Remove-DatabricksWorkspaceItem -Path $item.path
        }

        Invoke-DatabricksApi -Method POST -Path "workspace/delete" -Body @{
            path      = $item.path
            recursive = $true
        }

        Write-Host "Deleted $($item.path)"
    }
}

Write-Host "Cleaning Databricks /Shared workspace..." -ForegroundColor Yellow
Remove-DatabricksWorkspaceItem -Path "/Shared"

# -----------------------------
# Clean temp
# -----------------------------
if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir }
if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }

# -----------------------------
# Download GitHub repo (zip)
# -----------------------------
Write-Host "Downloading GitHub repo..." -ForegroundColor Cyan

$zipUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/zipball/$Branch"
$ghHeaders = @{ "User-Agent" = "PowerShell" }
if ($GitHubToken) { $ghHeaders["Authorization"] = "token $GitHubToken" }

Invoke-RestMethod -Uri $zipUrl -Headers $ghHeaders -OutFile $ZipPath

# -----------------------------
# Extract
# -----------------------------
Write-Host "Extracting repo..." -ForegroundColor Cyan
Expand-Archive -Path $ZipPath -DestinationPath $TempDir

$RepoRoot = Get-ChildItem $TempDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1

# -----------------------------
# Create workspace root
# -----------------------------
Write-Host "Ensuring Databricks workspace folders exist..." -ForegroundColor Cyan

Invoke-DatabricksApi -Method POST -Path "workspace/mkdirs" -Body @{
    path = $WorkspaceRoot
}

Get-ChildItem $RepoRoot.FullName -Recurse -Directory | ForEach-Object {
    $relativePath = $_.FullName.Substring($RepoRoot.FullName.Length).Replace("\", "/")
    $workspacePath = "$WorkspaceRoot$relativePath"

    Invoke-DatabricksApi -Method POST -Path "workspace/mkdirs" -Body @{
        path = $workspacePath
    }

    Write-Host "Created folder $workspacePath"
}
# -----------------------------
# Upload files
# -----------------------------
Write-Host "Uploading files to Databricks workspace..." -ForegroundColor Cyan

(Get-ChildItem $RepoRoot.FullName -Recurse -File) | ForEach-Object {
    $relativePath = $_.FullName.Substring($RepoRoot.FullName.Length).Replace("\", "/")
    $workspacePath = "$WorkspaceRoot$relativePath"

    $content = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName))

    Invoke-DatabricksApi -Method POST -Path "workspace/import" -Body @{
        path      = $workspacePath
        format    = "AUTO"
        language  = "PYTHON"
        content   = $content
        overwrite = $true
    }

    Write-Host "Uploaded $workspacePath"
}

Write-Host "Done uploading repo to Databricks workspace" -ForegroundColor Green
if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir }
if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }

