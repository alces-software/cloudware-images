#!/bin/bash
AZURE_REGION=uksouth
AZURE_RESOURCE_GROUP=alces-cloudware
IMAGE_NAME=alces-cloudware-base-2019.1.0-azure

#
# Only use Azure regions that support storageAccount resources.
#
# This is to avoid:
#   output: ERROR: The provided location 'francesouth' is not available for resource type 'Microsoft.Storage/storageAccounts'.
#
# When copying the image, it requires creation of a storageAccount as a temporary space.
#
#AZURE_REGIONS=$(az account list-locations |grep name |awk '{print $2}' |grep -v $AZURE_REGION |sed 's/"//g;s/,//g')
AZURE_REGIONS=$(az provider show --namespace Microsoft.Storage --query "resourceTypes[?resourceType=='storageAccounts'].locations | [0]" -o tsv |sed 's/ //g' | tr '[:upper:]' '[:lower:]' |grep -v $AZURE_REGION |sort)

# Print to JSON for ARM Templates
echo
echo
echo "\"images\": {
  {
    \"$AZURE_REGION\": \"$(az image show --name $IMAGE_NAME --resource-group $AZURE_RESOURCE_GROUP |grep id -m 1 |awk '{print $2}')\"
  },"

for region in $AZURE_REGIONS ; do
    IMAGE=$(az image show --name $IMAGE_NAME-$region --resource-group $AZURE_RESOURCE_GROUP |grep id -m 1 |awk '{print $2}')
    echo "  {"
    echo "    \"$region\": \"$IMAGE\""
    echo "  },"
done
echo "}"
