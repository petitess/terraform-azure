### https://github.com/terraform-linters/tflint

#### .tflint.hcl
```hcl
tflint {
  required_version = ">= 0.55.0"
}

plugin "terraform" {
  enabled = true
  version = "0.10.0"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  preset  = "recommended"
}

plugin "azurerm" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
```
#### plan.yml
```yml
name: 'Build Terraform - Infra'

on:
  workflow_dispatch:

jobs:
  terraform_build_and_plan:
    name: 'Terraform Build & Plan'
    runs-on: self-hosted
    steps:
    - name: Setup TFLint
      uses: terraform-linters/setup-tflint@v4

    - name: Init TFLint
      run: tflint --init

    - name: Run TFLint
      run: tflint
```
