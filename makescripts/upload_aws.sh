#!/bin/bash
$QEMU_IMG_BIN convert -f qcow2 -O raw \
	$VM_DIR/converted/$IMAGE_NAME.qcow2 \
	$VM_DIR/$IMAGE_NAME.raw

cp container.json /tmp/$IMAGE_NAME.json
sed -i -e "s/%IMAGE_NAME%/$IMAGE_NAME/g" \
	-e "s/%AWS_BUCKET_NAME%/$AWS_BUCKET/g" \
	-e "s/%AWS_BUCKET_DIR%/$AWS_BUCKET_DIR/g" \
	/tmp/$IMAGE_NAME.json

aws --region $AWS_REGION s3 cp $VM_DIR/$IMAGE_NAME.raw s3://$AWS_BUCKET/$AWS_BUCKET_DIR/$IMAGE_NAME.raw 

IMPORT_TASK=$(aws ec2 import-image --architecture x86_64 \
                --region $AWS_REGION \
                --description "$IMAGE_NAME" \
                --disk-containers "file:///tmp/$IMAGE_NAME.json" \
                --platform Linux \
                --license-type BYOL)
IMPORT_TASK_ID=$(echo "$IMPORT_TASK" |grep ImportTaskId |sed 's/.*: //g;s/"//g')

if [[ "$IMPORT_TASK_ID" == "" ]] ; then
    echo "No import task found, exiting before things go really bad"
    exit 1
fi

while [[ "$(aws ec2 describe-import-image-tasks --region $AWS_REGION --import-task-ids $IMPORT_TASK_ID |grep ImageId |awk '{print $2}' |sed 's/"//g;s/,//g')" == "" ]] ; do
    echo "Waiting for import of $IMAGE_NAME on $PLATFORM to complete..."
    sleep 30
done

AMI_ID=$(aws ec2 describe-import-image-tasks --region $AWS_REGION --import-task-ids $IMPORT_TASK_ID |grep ImageId |sed 's/.*: //g;s/"//g;s/,//g;s/[//g;s/]//g')

echo "Renaming $IMPORT_TASK_ID to $IMAGE_NAME"
aws ec2 copy-image --source-image-id $AMI_ID --source-region $AWS_REGION --region $AWS_REGION --name $IMAGE_NAME --description $IMAGE_NAME

echo "Removing old AMI"
aws ec2 deregister-image --image-id $AMI_ID --region $AWS_REGION
