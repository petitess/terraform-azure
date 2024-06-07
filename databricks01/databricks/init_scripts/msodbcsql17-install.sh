#!/bin/bash

USERNAME=${PYPI_USER}
PASSWORD=${PYPI_PW}

#curl -um7217401:cmVmdGtuOjAxOjE3NDYwMD -L -O https://artifacts.comp.com/artifactory/comp/odbc/msodbcsql17_17.10.#1.1-1_amd64.deb
#sudo ACCEPT_EULA=Y apt-get -q -y install ./msodbcsql17_17.10.1.1-1_amd64.deb

curl -u${USERNAME}:${PASSWORD} -L -O https://artifacts.comp.com/artifactory/comp/odbc/msodbcsql17_17.10.1.1-1_amd64.deb
sudo ACCEPT_EULA=Y apt-get -q -y install ./msodbcsql17_17.10.1.1-1_amd64.deb


#curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
#curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
#sudo apt-get update
#sudo ACCEPT_EULA=Y apt-get -q -y install msodbcsql17