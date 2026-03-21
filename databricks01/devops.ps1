#!/usr/bin/env pwsh

$ErrorActionPreference = 'Stop'

az extension add --name azure-devops

$Products = (Get-ChildItem -Path './ci').Name
$System = 'system'

$Org = "https://dev.azure.com/B3Cloud"
$Project = "B3Care"
$Repo = 'datafactory'
az repos list --query [].name -o tsv

foreach ($Product in $Products | Where-Object { $_ -notmatch "devops.ps1" -and $_ -like "ci-*.yml" }) {
    if (!(az pipelines show --org $Org --project $Project  --name $Product.Replace(".yml", "") 2> $null)) {
        $Product -like "ci-*.yml"
        az pipelines create --org $Org --project $Project --name $Product.Replace(".yml", "") --yml-path "ci/$Product" --folder-path $System --branch main --repository $Repo --repository-type 'tfsgit' --query definition.uri
        Write-Output "Created CI pipeline for $Product"
    }
    Write-Output $Product
}

foreach ($Product in $Products | Where-Object { $_ -notmatch "devops.ps1" -and $_ -like "cd-*.yml" }) {

    if (!(az pipelines show --org $Org --project $Project  --name $Product.Replace(".yml", "") 2> $null)) {
        az pipelines create --org $Org --project $Project --name $Product.Replace(".yml", "") --yml-path "ci/$Product" --folder-path $System --branch main --repository $Repo --repository-type 'tfsgit' --query definition.uri
        Write-Output "Created CD pipeline for $Product"
    }
    Write-Output $Product
}

foreach ($Product in $Products | Where-Object { $_ -notmatch "devops.ps1" -and $_ -like "ci-*.yml" } ) {
    $repoName = $Repo
    $repoId = az repos list --org $Org --project $Project --query "[?name=='$repoName'].id" -o tsv
    $pipelineName = $Product.Replace(".yml", "")
    $buildId = az pipelines build definition list --org $Org --project $Project --repository $Repo --query "[?name=='$pipelineName'].id" -o tsv
    $policyValidation = az repos policy list --org $Org --project $Project --query "[?settings.displayName=='$pipelineName']" -o tsv

    if ($null -eq $policyValidation) {
        Write-Output "Creating Build Validation policy: $pipelineName."
        az repos policy build create --blocking true `
            --branch "refs/heads/main" `
            --org $Org `
            --project $Project `
            --build-definition-id $buildId `
            --display-name $pipelineName `
            --enabled true `
            --manual-queue-only false `
            --queue-on-source-update-only false `
            --repository-id $repoId `
            --valid-duration "0.0" `
            --path-filter  $($Product -eq "infra" ? "/landingzones/$Product/*;/ci/templates/ci.yml;/iac/*" : "/terraform/*") `
            --query type.url
    }
    else {
        Write-Output "Build Validation policy already exists: $pipelineName."
    }
}