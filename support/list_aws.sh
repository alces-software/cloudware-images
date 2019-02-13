#!/bin/bash
AWS_REGION=eu-west-2
IMAGE_NAME=alces-cloudware-base-2019.1.0-aws

AWS_REGIONS=$(aws ec2 describe-regions |grep RegionName |awk '{print $2}' |grep -v $AWS_REGION |sed 's/"//g')
AMI=$(aws ec2 describe-images --filters Name=name,Values=$IMAGE_NAME --region $AWS_REGION |grep ImageId |awk '{print $2}' |sed 's/"//g;s/,//g')

# Print YAML for use in CloudFormation templates
echo
echo
echo "RegionMap:"
echo "  $AWS_REGION:"
echo "    \"AMI\": \"$AMI\""
for region in $AWS_REGIONS ; do
    ami=$(aws ec2 describe-images --filters Name=name,Values=$IMAGE_NAME --region $region |grep ImageId |awk '{print $2}' |sed 's/"//g;s/,//g')
    echo "  $region:"
    echo "    \"AMI\": \"$ami\""
done
