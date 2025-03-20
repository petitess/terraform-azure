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