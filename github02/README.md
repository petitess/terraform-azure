## Prereq
`az login --scope https://storage.azure.com//.default`
```
terraform init -backend-config="storage_account_name=stabcdedevweu" -reconfigure
terraform plan -var=env=dev -var=gh_pat=ghp_abcd1234
terraform apply --auto-approve -var=env=dev -var=gh_pat=ghp_abcd1234
```
```
terraform init -backend-config="storage_account_name=stabcdeprdweu" -reconfigure
terraform plan -var=env=prd -var=gh_pat=ghp_abcd1234
terraform apply --auto-approve -var=env=prd -var=gh_pat=ghp_abcd1234
```