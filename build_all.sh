#!/bin/bash
PLATFORMS="aws azure"
AWS_REGION=eu-west-1
AZURE_REGION=uksouth

IMAGE_TYPE=alces-cloudware-base
IMAGE_VERSION=2019.1.0
IMAGE_NAME=$(IMAGE_TYPE)-$(IMAGE_VERSION)-$(date +%F_%H-%M)

echo "========================================================="
echo "Creating AMI '$IMAGE_NAME' on $PLATFORMS"
echo "========================================================="

for platform in $PLATFORMS ; do
    echo "Making $platform"
    echo "make image PLATFORM=$platform AWS_REGION=$AWS_REGION AZURE_REGION=$AZURE_REGION IMAGE_TYPE=$IMAGE_TYPE IMAGE_NAME=$IMAGE_NAME"
done

# Run the copy script here

# AWS copy
AWS_REGIONS=$(aws ec2 describe-regions |grep RegionName |awk '{print $2}' |grep -v $AWS_REGION |sed 's/"//g')
AMI=$(aws ec2 describe-images --filters Name=name,Values=$IMAGE_NAME |grep ImageId)
for region in $AWS_REGIONS ; do
    echo "Copying $AMI to $region"
    echo "aws ec2 copy-image --source-region $AWS_REGION --region $region"
done

# Azure copy

