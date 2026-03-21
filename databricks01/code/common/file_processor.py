import base64
import json
import logging

import requests

from .proxy_utils import SG_PROXY


class FileProcessor:
    def __init__(
        self, vcs_handler, databricks_handler, vcs_system, exclusion_list=None
    ):
        self.vsc_system = vcs_system
        self.vcs_handler = vcs_handler
        self.databricks_handler = databricks_handler
        self.exclusion_list = exclusion_list if exclusion_list else []

    @staticmethod
    def _should_exclude(current_path, folders_to_exclude):
        return folders_to_exclude and any(
            current_path.startswith(excluded_folder)
            for excluded_folder in folders_to_exclude
        )

    def process_files(self, files, path_prefix="", folders_to_exclude=None):
        for file in files:
            normalized_file = self.vcs_handler.normalize_file(file)
            current_path = f"{path_prefix}/{normalized_file['name']}".strip("/")

            current_path = self._handle_leading_folder(current_path)

            if self._should_exclude(current_path, folders_to_exclude):
                logging.info(f"Skipping everything in folder: {current_path}")
                continue

            is_file = normalized_file["type"] == "file"
            is_dir = normalized_file["type"] == "dir"
            should_exclude_current_file = (
                current_path.split("/")[-1] in self.exclusion_list
            )
            file_exists_in_databricks = self.databricks_handler.file_exists(
                f"/Shared/{current_path}"
            )

            if is_file:
                if should_exclude_current_file and file_exists_in_databricks:
                    logging.info(f"Skipping existing file: {current_path}")
                    continue
                self._download_file_from_vsc_and_upload_to_databricks(
                    current_path, normalized_file
                )

            elif is_dir:
                logging.info(f"handling directory: {current_path}")
                if not self._should_exclude(current_path, folders_to_exclude):
                    self.databricks_handler.create_directory(f"/Shared/{current_path}")
                    logging.info(f"Created directory: /Shared/{current_path}")
                    sub_files = self.get_sub_files(file, normalized_file)
                    self.process_files(
                        files=sub_files,
                        path_prefix=current_path,
                        folders_to_exclude=folders_to_exclude,
                    )

    def _download_file_from_vsc_and_upload_to_databricks(
        self, current_path, normalized_file
    ):
        download_url = normalized_file["download_url"]
        logging.info(f"Download url: {download_url}")
        file_content = self.fetch_file_content(download_url)
        is_github = self.vsc_system == "github"
        if is_github:
            file_content = base64.b64decode(json.loads(file_content)["content"])
        self.databricks_handler.upload_file(current_path, file_content)
        logging.info(f"Done uploading file: {current_path}")

    @staticmethod
    def _handle_leading_folder(current_path):
        if current_path.startswith("customer-notebook"):
            current_path = current_path.replace("customer-notebook", "", 1).strip("/")
        return current_path

    def get_sub_files(self, file, normalized_file):
        if self.vsc_system == "github":
            sub_files = self.vcs_handler.fetch_tree_entries(normalized_file["path"])
        elif self.vsc_system == "azuredevops":
            sub_files = self.vcs_handler.fetch_tree_entries(file["url"])
        else:
            raise NotImplementedError(f"VCS system not supported: {self.vsc_system}")

        return sub_files

    def fetch_file_content(self, file_url):
        headers = self.vcs_handler._get_headers()
        response = requests.get(file_url, headers=headers, proxies=SG_PROXY)

        if response.status_code == 200:
            return response.content
        else:
            raise RuntimeError(
                f"Failed to fetch file content: {response.status_code} - {response.text}"
            )
