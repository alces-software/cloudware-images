echo "Converting $IMAGE_NAME to RAW format"
$QEMU_IMG_BIN convert -f qcow2 -O raw \
	$VM_DIR/converted/$IMAGE_NAME.qcow2 \
	$VM_DIR/$IMAGE_NAME.raw

echo "Converting $IMAGE_NAME to VHD format"
$QEMU_IMG_BIN convert -f raw -O vpc -o subformat=fixed,force_size \
	$VM_DIR/$IMAGE_NAME.raw \
	$VM_DIR/$IMAGE_NAME.vhd

echo "Creating resource group"
az group create --name $AZURE_RESOURCE_GROUP \
	--location $AZURE_REGION

echo "Creating storage account"
az storage account create --name $AZURE_STORAGE_ACCOUNT \
	--resource-group $AZURE_RESOURCE_GROUP \
	--location $AZURE_REGION \
	--sku Standard_LRS \
	--encryption blob

echo "Creating storage container"
az storage container create --name $AZURE_STORAGE_CONTAINER \
	--account-name $AZURE_STORAGE_ACCOUNT \
	--account-key $(az storage account keys list --account-name $AZURE_STORAGE_ACCOUNT -o tsv |head -1 |cut -f3)

echo "Uploading $IMAGE_NAME to $AZURE_IMAGE_URL"
az storage blob upload --account-name $AZURE_STORAGE_ACCOUNT \
	--container-name $AZURE_STORAGE_CONTAINER \
	--type page \
	--file $VM_DIR/$IMAGE_NAME.vhd \
	--name $IMAGE_NAME.vhd
az image create --resource-group $AZURE_RESOURCE_GROUP \
	--name $IMAGE_NAME \
	--location $AZURE_REGION \
	--os-type Linux \
	--source $AZURE_IMAGE_URL
