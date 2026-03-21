from dataclasses import dataclass, field
from typing import List, Dict

from .databricks_auth_parameters import DatabricksAuthParameters


@dataclass
class CreateClusterParameters:
    auth: DatabricksAuthParameters
    cluster_name: str = "main"
    spark_version: str = "12.2.x-scala2.12"
    node_type_id: str = "Standard_DS3_v2"
    min_num_workers: int = 2
    max_num_workers: int = 8
    init_scripts: List[dict] = field(default_factory=list)
    spark_env_vars: Dict[str, str] = field(default_factory=dict)
