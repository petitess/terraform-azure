from dataclasses import dataclass
from typing import Optional


@dataclass
class DatabricksAuthParameters:
    databricks_azure_resource_id: Optional[str] = None
    azure_client_id: Optional[str] = None
    azure_client_secret: Optional[str] = None
    azure_tenant_id: Optional[str] = None
    host: Optional[str] = None
    token: Optional[str] = None
