#!/bin/bash

# Define variables for basic auth credentials
USERNAME=${KEY_VAULT_USER}
PASSWORD=${KEY_VAULT_PW}

PYPI_BASE_URL="abc.com/artifactory/api/pypi/pypi/simple"
WADE_PYPI_BASE_URL="abc.com/artifactory/api/pypi/sgds-055-analytics-wade/simple"

# Install packages using pip with basic auth in the URL
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${WADE_PYPI_BASE_URL}" wadenotebook==0.1.1236
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${PYPI_BASE_URL}" azure-storage-blob
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${PYPI_BASE_URL}" pyodbc
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${PYPI_BASE_URL}" azure-storage-file-datalake
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${PYPI_BASE_URL}" azure-identity