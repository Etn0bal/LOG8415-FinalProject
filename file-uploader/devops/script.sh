#!/bin/bash
terraform apply -auto-approve

terraform output -json | jq -r '@sh "export REACT_APP_STORAGESASTOKEN=\(.storage_sas_token.value)\nexport REACT_APP_STORAGERESOURCENAME=\(.storage_account_name.value)\nexport REGISTRY_PASSWORD=\(.registry_password.value)"' > env.sh
source env.sh 

docker build -t fileuploaderacr.azurecr.io/file-uploader:latest --build-arg STORAGE_SAS_TOKEN=$REACT_APP_STORAGESASTOKEN --build-arg STORAGE_RESOURCE_NAME=$REACT_APP_STORAGERESOURCENAME ../

docker push fileuploaderacr.azurecr.io/file-uploader:latest

az webapp config container set --resource-group file-uploader-rg --name file-uploader-app --docker-registry-server-url http://fileuploaderacr.azurecr.io --docker-registry-server-user fileuploaderacr --docker-registry-server-password $REGISTRY_PASSWORD