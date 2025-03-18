package main

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"

	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/keyvault/armkeyvault"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var sub_id string = "123"

func TestTerraform_kv(t *testing.T) {
	// Construct the terraform options with default retryable errors to handle the most common
	// retryable errors in terraform testing.
	os.Setenv("AzureCLIPath", "C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin")
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// Set the path to the Terraform code that will be tested.
		TerraformDir: "./provision-test",
	})
	// Clean up resources with "terraform destroy" at the end of the test.
	//defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply". Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables and check they have the expected values.
	output := terraform.Output(t, terraformOptions, "kv_public_access")
	assert.Equal(t, "true", output)

	kvE, _ := azure.GetKeyVaultE(t, "rg-unitest-01", "kv-sys-unitest-01", sub_id)
	assert.Equal(t, true, *kvE.Properties.EnableSoftDelete)
	assert.Equal(t, false, *kvE.Properties.EnabledForDiskEncryption)

	cred, clientFactory, options := AuthencticateToAzure()
	CreateSecret(cred, clientFactory, options)

}

func AuthencticateToAzure() (*azidentity.DefaultAzureCredential, *armkeyvault.ClientFactory, arm.ClientOptions) {
	cred, _ := azidentity.NewDefaultAzureCredential(nil)
	clientFactory, _ := armkeyvault.NewClientFactory(sub_id, cred, nil)
	options := arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{
			Cloud: cloud.AzureChina,
		},
	}
	return cred, clientFactory, options
}

func CreateSecret(cred *azidentity.DefaultAzureCredential, clientFactory *armkeyvault.ClientFactory, options arm.ClientOptions) {
	t := time.Now()
	msg := "created by terratest " + t.Format("2006-01-02")
	client := clientFactory.NewSecretsClient()
	client.CreateOrUpdate(context.Background(), "rg-unitest-01", "kv-sys-unitest-01", "terratest", armkeyvault.SecretCreateOrUpdateParameters{
		Properties: &armkeyvault.SecretProperties{Value: &sub_id, ContentType: &msg},
	}, &armkeyvault.SecretsClientCreateOrUpdateOptions{})
}
