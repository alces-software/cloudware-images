#!/bin/bash
export PLATFORMS="aws azure"
export AWS_REGION=eu-west-1
export AZURE_REGION=uksouth

export IMAGE_TYPE=alces-cloudware-base
export IMAGE_VERSION=2019.1.0
export IMAGE_NAME=$IMAGE_TYPE-$IMAGE_VERSION-$(date +%F_%H-%M)

echo "========================================================="
echo "Creating AMI '$IMAGE_NAME' on $PLATFORMS"
echo "========================================================="

for platform in $PLATFORMS ; do
    echo "Making $platform"
    echo "make image PLATFORM=$platform AWS_REGION=$AWS_REGION AZURE_REGION=$AZURE_REGION IMAGE_TYPE=$IMAGE_TYPE IMAGE_NAME=$IMAGE_NAME"
done


#
# Wait for images to be imported
#
for platform in $PLATFORMS ; do 
    export PLATFORM=$platform
    echo "bash wait_for_image.sh &"
done

wait

#
# AWS copy
#
export AWS_REGIONS=$(aws ec2 describe-regions |grep RegionName |awk '{print $2}' |grep -v $AWS_REGION |sed 's/"//g')
export AMI=$(aws ec2 describe-images --filters Name=name,Values=$IMAGE_NAME |grep ImageId |awk '{print $2}' |sed 's/"//g;s/,//g')
for region in $AWS_REGIONS ; do
    echo "Copying $AMI to $region"
    echo "aws ec2 copy-image --source-region $AWS_REGION --region $region"
done

#
# Azure copy
#
export AZURE_REGIONS=$(az account list-locations |grep name |awk '{print $2}' |grep -v $AZURE_REGION |sed 's/"//g;s/,//g')
export IMAGE=$()
for region in $AZURE_REGIONS ; do
    echo "Copying $IMAGE to $region"
    echo "az image copy --source-resource-group mySources-rg --source-object-name myImage --target-location uksouth northeurope --target-resource-group 'images-repo-rg' --cleanup"
done


#
# Image ID locating
#

# Query $IMAGE_NAME in every region and print in appropriate format for templates
