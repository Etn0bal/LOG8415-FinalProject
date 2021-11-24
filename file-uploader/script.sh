#!/bin/bash

REACT_APP_STORAGESASTOKEN='?sv=2017-07-29&ss=b&srt=sco&sp=rwdlacup&se=2022-03-21T00:00:00Z&st=2021-03-21T00:00:00Z&spr=https&sig=9b9I%2BegT%2Fb6akEthhmurHYAc16bFdxlDkipkwoGhTuk%3D'
REACT_APP_STORAGERESOURCENAME=fileuploaderst
REGISTRY_PASSWORD=BBJCroSi=NWbhYTvMF+l=aYuKmP/ShfW

docker build -t fileuploaderacr.azurecr.io/file-uploader:latest --build-arg STORAGE_SAS_TOKEN=$REACT_APP_STORAGESASTOKEN --build-arg STORAGE_RESOURCE_NAME=$REACT_APP_STORAGERESOURCENAME .

docker push fileuploaderacr.azurecr.io/file-uploader:latest

#az acr build --build-arg STORAGE_SAS_TOKEN=$REACT_APP_STORAGESASTOKEN --build-arg STORAGE_RESOURCE_NAME=$REACT_APP_STORAGERESOURCENAME --image file-uploader --registry fileuploaderacr .
az webapp config container set --resource-group file-uploader-rg --name file-uploader-app --docker-registry-server-url http://fileuploaderacr.azurecr.io --docker-registry-server-user fileuploaderacr --docker-registry-server-password $REGISTRY_PASSWORD