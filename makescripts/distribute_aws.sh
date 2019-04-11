#!/bin/bash
export AWS_REGIONS=$(aws ec2 describe-regions |grep RegionName |awk '{print $2}' |grep -v $AWS_REGION |sed 's/"//g')
export AMI=$(aws ec2 describe-images --filters Name=name,Values=$IMAGE_NAME --region $AWS_REGION |grep ImageId |awk '{print $2}' |sed 's/"//g;s/,//g')
for region in $AWS_REGIONS ; do
    echo "Copying $AMI to $region"
    aws ec2 copy-image --source-region $AWS_REGION --source-image-id $AMI --region $region --name $IMAGE_NAME --description $IMAGE_NAME
done

