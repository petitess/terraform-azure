```
go mod init test.org/abc
go mod tidy
go test -v -timeout 60m
go run .
```
```
go get -u github.com/gruntwork-io/terratest/modules/terraform
go get -u github.com/stretchr/testify/assert
```
To fix: 'az' is not recognized as an internal or external command

$env:AzureCLIPath = "C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin"