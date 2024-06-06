#!/usr/bin/env pwsh

param (
    [Parameter(Mandatory)]
    [String]$Environment
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot
$Config = Get-Content 'config.json' | ConvertFrom-Json

$SubId = $(az account show --name $Config.sub.$Environment --query id -o tsv)
$TenantId = $(az account show --query tenantId -o tsv)

Write-Host "ENV: $Environment"
Write-Host "SUB: $($SubId.Substring(0, 15))"
Write-Host "TEN: $($TenantId.Substring(0, 15))"


terraform init -input=false `
    -backend-config="storage_account_name=$($Config.storage.$Environment)" `
    -backend-config="subscription_id=$SubId" `
    -backend-config="tenant_id=$TenantId "

terraform plan -out=tfplan -input=false -var="env=$Environment" -var="subid=$SubId"