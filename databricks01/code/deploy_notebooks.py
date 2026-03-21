import json
import logging
import os
from common.databricks_handler import DatabricksHandler
from common.deploy_notebook_parameters import DeployNotebookParameters
from common.file_processor import FileProcessor
from common.vcs_handler import AzureDevOpsHandler, GitHubHandler
from common.databricks_auth_parameters import DatabricksAuthParameters

APPLICATION_JSON = "application/json"
databricks_azure_resource_id = os.getenv("databricks_azure_resource_id")
azure_client_id = os.getenv("azure_client_id")
azure_client_secret = os.getenv("azure_client_secret")
azure_tenant_id = os.getenv("azure_tenant_id")
github_token = os.getenv("github_token")

auth = {
    "databricks_azure_resource_id": databricks_azure_resource_id,
    "azure_client_id": azure_client_id,
    "azure_client_secret": azure_client_secret,
    "azure_tenant_id": azure_tenant_id,
}

body = {
    "auth": auth,
    "branch": "main",
    "repo_url": "https://api.github.com/repos/petitess/python/contents",
    "vcs_token": github_token,
    "files_not_to_delete": ["config.json", "config.json.info.md"],
    "folders_to_exclude": ["prerequisites", ".github"],
}

print("body:", body)

try:
    # data = req.get_json()
    auth_params = DatabricksAuthParameters(**body.pop("auth"))
    params = DeployNotebookParameters(auth=auth_params, **body)
except ValueError as ve:
    json.dumps({"message": str(ve)}),
    headers = ({"Content-Type": APPLICATION_JSON},)
    status_code = (400,)

if "github" in params.repo_url.lower():
    vcs_handler = GitHubHandler(params.repo_url, params.branch, params.vcs_token)
else:
    vcs_handler = AzureDevOpsHandler(params.repo_url, params.branch, params.vcs_token)

databricks_handler = DatabricksHandler(
    databricks_azure_resource_id=params.auth.databricks_azure_resource_id,
    azure_client_id=params.auth.azure_client_id,
    azure_client_secret=params.auth.azure_client_secret,
    azure_tenant_id=params.auth.azure_tenant_id,
    host=params.auth.host,
    token=params.auth.token,
)

logging.info(
    f"Clearing Databricks workspace, except for {', '.join(params.files_not_to_delete) if params.files_not_to_delete else 'nothing'}"
)

databricks_handler.clear_workspace(exclusion_list=params.files_not_to_delete)
logging.info("Done clearing Databricks workspace")

logging.info("Fetching files from VCS")
try:
    root_response = vcs_handler.fetch_files("/")
    logging.info(f"Root response: {root_response}")
except Exception as e:
    logging.error(f"Error while fetching files from VCS: {str(e)}")
    json.dumps({"message": str(e)}),
    headers = ({"Content-Type": APPLICATION_JSON},)
    status_code = (500,)

if isinstance(root_response, list):
    files = root_response
elif "gitObjectType" in root_response and root_response["gitObjectType"] == "tree":
    files = vcs_handler.fetch_tree_entries(root_response["_links"]["tree"]["href"])
else:
    raise RuntimeError("Unexpected response structure from VCS")

logging.info("Initiating file deployment")
file_processor = FileProcessor(
    vcs_handler=vcs_handler,
    databricks_handler=databricks_handler,
    exclusion_list=params.files_not_to_delete,
    vcs_system="github" if isinstance(root_response, list) else "azuredevops",
)
logging.info("Processing files")
file_processor.process_files(files=files, folders_to_exclude=params.folders_to_exclude)
logging.info("Done processing files")
