from dataclasses import dataclass, field
from typing import Optional, List

from .databricks_auth_parameters import DatabricksAuthParameters


@dataclass
class DeployNotebookParameters:
    auth: DatabricksAuthParameters
    branch: str
    # DevOps
    # ex. https://dev.azure.com/fabrikam/1e080d59-1a53-4218-99b2-29ad0b9662c9/_apis/git/repositories/2270983a-9710-4a1e-af38-f20d322b1f1c/items
    # GitHub
    # ex. https://api.github.com/repos/Fjurg/phptravelstest/contents
    repo_url: str
    vcs_token: str
    files_not_to_delete: Optional[List[str]] = field(
        default_factory=lambda: ["config.json", "config.json.info.md"]
    )
    folders_to_exclude: Optional[List[str]] = field(default_factory=list)
