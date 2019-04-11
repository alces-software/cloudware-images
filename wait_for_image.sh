#!/bin/bash
PLATFORM=${PLATFORM:-aws}
IMAGE_NAME=${IMAGE_NAME:-$1}

# AWS
if [[ $PLATFORM == "aws" ]] ; then
    while [[ "$(aws ec2 describe-images --filters Name=name,Values=$IMAGE_NAME |grep ImageId |awk '{print $2}' |sed 's/"//g;s/,//g')" == "" ]] ; do 
        echo "Waiting for import of $IMAGE_NAME on $PLATFORM to complete..."
        sleep 10
    done
fi

# Azure
if [[ $PLATFORM == "azure" ]] ; then
    while [[ "$()" == "" ]] ; do
        echo "Waiting for import $IMAGE_NAME on $PLATFORM to complete..."
        sleep 10
    done
fi
