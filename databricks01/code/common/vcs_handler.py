import base64
import logging
from abc import abstractmethod, ABC

import requests

from .proxy_utils import SG_PROXY


class VCSHandler(ABC):
    def __init__(self, repo_url: str, branch: str = "main", token: str = None):
        self.repo_url = repo_url
        self.branch = branch
        self.token = token

    @abstractmethod
    def fetch_files(self, path=""):
        pass

    def _get_headers(self):
        headers = {}
        if self.token:
            headers["Authorization"] = self._get_auth_header()
        return headers

    @abstractmethod
    def _get_auth_header(self):
        pass


class GitHubHandler(VCSHandler):
    def fetch_files(self, path=""):
        url = (
            f"{self.repo_url}?ref={self.branch}"
            if not path
            else f"{self.repo_url}/{path}?ref={self.branch}"
        )
        logging.info(f"Fetching files from GitHub: {url}")
        headers = self._get_headers()

        try:
            response = requests.get(url, headers=headers, proxies=SG_PROXY)
            logging.info(f"Response from GitHub: {response.status_code}: {response.text}")
        except requests.exceptions.RequestException as e:
            logging.error(f"Network-related error occurred: {str(e)}")
            raise

        if response.status_code == 200:
            return response.json()

    def fetch_tree_entries(self, path):
        return self.fetch_files(path)

    def normalize_file(self, file):
        return {
            "name": file["name"],
            "path": file["path"],
            "type": file["type"],
            "download_url": file["git_url"] if file["type"] == "file" else None,
        }

    def _get_auth_header(self):
        return f"token {self.token}"


class AzureDevOpsHandler(VCSHandler):
    def fetch_files(self, path=""):
        url = f"{self.repo_url}?path={path}&versionDescriptor.version={self.branch}"
        headers = self._get_headers()
        response = requests.get(url, headers=headers, proxies=SG_PROXY)
        if response.status_code == 200:
            return response.json()
        else:
            raise RuntimeError(
                f"Failed to fetch files from Azure DevOps: {response.status_code} - {response.text}"
            )

    def fetch_tree_entries(self, tree_url):
        headers = self._get_headers()
        response = requests.get(tree_url, headers=headers, proxies=SG_PROXY)
        if response.status_code == 200:
            return response.json().get("treeEntries", [])
        else:
            raise RuntimeError(
                f"Failed to fetch tree from Azure DevOps: {response.status_code} - {response.text}"
            )

    def normalize_file(self, file):
        return {
            "name": file["relativePath"].split("/")[-1],
            "path": file["relativePath"],
            "type": "file" if file["gitObjectType"] == "blob" else "dir",
            "download_url": file["url"] if file["gitObjectType"] == "blob" else None,
        }

    def _get_auth_header(self):
        return f"Basic {self._encode_token(self.token)}"

    def _encode_token(self, token):
        return base64.b64encode(f":{token}".encode()).decode()
