#!/usr/bin/env pwsh

param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $PSScriptRoot/../spokes/$_ })]
    [String]$LandingZone = 'infra',

    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $PSScriptRoot/../spokes/$LandingZone/$_.tfvars })]
    [String]$Environment = 'dev'
)

$ErrorActionPreference = 'Stop'

Set-Location $PSScriptRoot
$Config = Get-Content "$LandingZone/config.json" | ConvertFrom-Json

$SubId = $(az account show --name $Config.sub.$Environment --query id -o tsv)
$TenantId = $(az account show --query tenantId -o tsv)

Write-Host "ENV: $Environment"
Write-Host "SUB: $($SubId.Substring(0, 15))"
Write-Host "TEN: $($TenantId.Substring(0, 15))"

terraform init -reconfigure -input=false `
    -backend-config="key=$($Config.tfstate.$Environment)" `
    -backend-config="subscription_id=$SubId" `
    -backend-config="tenant_id=$TenantId "

terraform apply -auto-approve -input=false `
-var="env=$Environment" `
-var="subid=$SubId" `
-var-file="$($LandingZone)/$($Environment).tfvars"