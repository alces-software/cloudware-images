#!/bin/bash
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

az extension add --name image-copy-extension

echo "Copying $IMAGE_NAME to all regions"
az image copy --source-resource-group $AZURE_RESOURCE_GROUP --source-object-name $IMAGE_NAME --target-location $(for region in $AZURE_REGIONS ; do echo -n "$region " ; done) --target-resource-group $AZURE_RESOURCE_GROUP --cleanup
