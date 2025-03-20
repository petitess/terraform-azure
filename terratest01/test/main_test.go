package main

import (
	"context"
	"errors"
	"os"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/keyvault/armkeyvault"
	"github.com/Azure/azure-sdk-for-go/sdk/storage/azblob"
	"github.com/Azure/azure-sdk-for-go/services/storage/mgmt/2019-06-01/storage"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

var sub_id string = "123"

var kv_name string = "kv-sys-unitest-01"
var kv_rg string = "rg-unitest-01"
var kv_secret string = "terratest"

var st_rg string = "rg-st-map-unitest-01"
var st_name string = "stmaunitest01"
var st_url string = "https://stmaunitest01.blob.core.windows.net/"
var st_container string = "terratest"

func TestTerraform_kv(t *testing.T) {
	os.Setenv("AzureCLIPath", "C:\\Program Files\\Microsoft SDKs\\Azure\\CLI2\\wbin")
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./provision-test",
	})
	//defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	output := terraform.Output(t, terraformOptions, "kv_public_access")
	assert.Equal(t, "true", output)

	kvE, _ := azure.GetKeyVaultE(t, kv_rg, kv_name, sub_id)
	assert.Equal(t, true, *kvE.Properties.EnableSoftDelete)
	assert.Equal(t, false, *kvE.Properties.EnabledForDiskEncryption)

	cred, clientFactory, options := AuthencticateToKeyVault()
	CreateSecret(cred, clientFactory, options)

	stE, _ := azure.GetStorageAccountE(st_name, st_rg, sub_id)
	assert.Equal(t, "Succeeded", string(*&stE.ProvisioningState))
	assert.Equal(t, "Deny", string(*&stE.AccountProperties.NetworkRuleSet.DefaultAction))

	clientBlob := getServiceClientTokenCredential(st_url)

	createContainer(clientBlob, st_container)

	blobExists, err := azure.StorageBlobContainerExistsE(st_container, st_name, st_rg, sub_id)
	if err != nil {
		errors.New("could not find container. " + err.Error())
	}
	assert.Equal(t, true, blobExists)
	deleteContainer(clientBlob, st_container)
}

func AuthencticateToKeyVault() (*azidentity.DefaultAzureCredential, *armkeyvault.ClientFactory, arm.ClientOptions) {
	cred, _ := azidentity.NewDefaultAzureCredential(nil)
	clientFactory, _ := armkeyvault.NewClientFactory(sub_id, cred, nil)
	options := arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{
			Cloud: cloud.AzurePublic,
		},
	}
	return cred, clientFactory, options
}

func CreateSecret(cred *azidentity.DefaultAzureCredential, clientFactory *armkeyvault.ClientFactory, options arm.ClientOptions) {
	t := time.Now()
	msg := "created by terratest " + t.Format("2006-01-02")
	client := clientFactory.NewSecretsClient()
	client.CreateOrUpdate(context.Background(), kv_rg, kv_name, kv_secret, armkeyvault.SecretCreateOrUpdateParameters{
		Properties: &armkeyvault.SecretProperties{Value: &sub_id, ContentType: &msg},
	}, &armkeyvault.SecretsClientCreateOrUpdateOptions{})
}

func AuthencticateToStorage() (*azidentity.DefaultAzureCredential, storage.BlobContainersClient, arm.ClientOptions) {
	cred, _ := azidentity.NewDefaultAzureCredential(nil)
	clientBlob := storage.NewBlobContainersClientWithBaseURI(st_url, sub_id)
	options := arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{
			Cloud: cloud.AzurePublic,
		},
	}
	return cred, clientBlob, options
}

func getServiceClientTokenCredential(accountURL string) *azblob.Client {
	credential, _ := azidentity.NewDefaultAzureCredential(nil)
	client, _ := azblob.NewClient(accountURL, credential, nil)
	return client
}

func createContainer(client *azblob.Client, containerName string) {
	_, err := client.CreateContainer(context.TODO(), containerName, nil)
	if err != nil {
		errors.New("could not create contaiiner. " + err.Error())
	}
}

func deleteContainer(client *azblob.Client, containerName string) {
	_, err := client.DeleteContainer(context.TODO(), containerName, nil)
	if err != nil {
		errors.New("could not create contaiiner. " + err.Error())
	}
}
