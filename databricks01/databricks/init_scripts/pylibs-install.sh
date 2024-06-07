#!/bin/bash

# Define variables for basic auth credentials
USERNAME=${PYPI_USER}
PASSWORD=${PYPI_PW}

PYPI_BASE_URL="artifacts.comp.com/artifactory/api/pypi/pypi/simple"
WADE_PYPI_BASE_URL="artifacts.comp.com/artifactory/api/pypi/comp/simple"

# Install packages using pip with basic auth in the URL
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${WADE_PYPI_BASE_URL}" wadenotebook==0.1.1316
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${PYPI_BASE_URL}" azure-storage-blob==12.19.1
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${PYPI_BASE_URL}" pyodbc==4.0.32
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${PYPI_BASE_URL}" azure-storage-file-datalake==12.14.0
/databricks/python/bin/pip install --extra-index-url "https://${USERNAME}:${PASSWORD}@${PYPI_BASE_URL}" azure-identity==1.16.0