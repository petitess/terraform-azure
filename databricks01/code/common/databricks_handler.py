import logging

from databricks.sdk import WorkspaceClient
from databricks.sdk.service.workspace import ImportFormat, Language


class DatabricksHandler:
    def __init__(self, **kwargs):
        self.databricks_azure_resource_id = kwargs.get("databricks_azure_resource_id")
        self.azure_client_id = kwargs.get("azure_client_id")
        self.azure_client_secret = kwargs.get("azure_client_secret")
        self.azure_tenant_id = kwargs.get("azure_tenant_id")
        self.host = kwargs.get("host")
        self.token = kwargs.get("token")
        self.client = self.get_client()

    def get_client(self):
        if self.azure_client_id:
            return WorkspaceClient(
                azure_workspace_resource_id=self.databricks_azure_resource_id,
                azure_client_id=self.azure_client_id,
                azure_client_secret=self.azure_client_secret,
                azure_tenant_id=self.azure_tenant_id,
            )
        return WorkspaceClient(
            host=self.host,
            token=self.token,
        )

    def upload_file(self, file_path, content_base64):
        self.client.workspace.upload(
            path=f"/Shared/{file_path}",
            content=content_base64,
            format=ImportFormat.AUTO,
            language=Language.PYTHON,
            overwrite=True,
        )

    def create_directory(self, dir_path):
        self.client.workspace.mkdirs(path=dir_path)

    def delete_item(self, path):
        self.client.workspace.delete(path=path, recursive=True)

    def clear_workspace(self, exclusion_list, path="/Shared"):
        try:
            workspace_list = self.client.workspace.list(path, recursive=True)
            logging.info("Successfully listed workspace")
        except Exception as e:
            logging.error(f"Path {path} does not exist")
            logging.exception("Error while listing workspace")
            raise e

        for item in workspace_list:
            item_name = item.path.split("/")[-1]

            if item.object_type == "DIRECTORY":
                continue

            if item_name not in exclusion_list:
                logging.info(f"Deleting file: {item.path}")
                self.delete_item(item.path)
            else:
                logging.info(f"Preserving file: {item.path}")

        workspace_list_after_deletes = self.client.workspace.list(path, recursive=True)
        for item in workspace_list_after_deletes:
            if item.object_type == "DIRECTORY":
                sub_items = self.client.workspace.list(item.path)
                if not sub_items:  # If the directory is empty, delete it
                    logging.info(f"Deleting empty directory: {item.path}")
                    self.delete_item(item.path)

    def file_exists(self, file_path):
        try:
            self.client.workspace.get_status(file_path)
            return True
        except Exception as e:
            # logging.error(f"File {file_path} does not exist. Error: {str(e)}")
            return False
