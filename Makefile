#==============================================================================
# Copyright (C} 2018 Stephen F Norledge & Alces Software Ltd.
#
# This file is part of Alces Cloudware.
#
# Some rights reserved, see LICENSE.
#==============================================================================

SHELL := /bin/bash

# Image config
# default to aws
export PLATFORM=aws
export IMAGE_TYPE=openflight-cloud-base
export IMAGE_VERSION=1.0
export IMAGE_NAME=${IMAGE_TYPE}-${IMAGE_VERSION}-${PLATFORM}

# Libvirt/Oz config
export KICKSTART=${IMAGE_TYPE}-${PLATFORM}.ks
export KICKSTART_RENDERED=/tmp/${IMAGE_NAME}.ks
export TDL=centos7.tdl
export TDL_RENDERED=/tmp/${IMAGE_NAME}.tdl
export OZ_CFG=oz.cfg
export VM_DIR=/opt/vm
export QEMU_IMG_BIN=/root/qemu/bin/qemu-img
export XML=domain.xml
export XML_RENDERED=${IMAGE_NAME}.xml

# AWS config
export AWS_BUCKET=openflight-cloud
export AWS_BUCKET_DIR=images
export AWS_REGION=eu-west-2

# Azure config
export AZURE_STORAGE_ACCOUNT=openflightcloud
export AZURE_STORAGE_CONTAINER=images
export AZURE_RESOURCE_GROUP=openflight-cloud
export AZURE_IMAGE_URL=https://${AZURE_STORAGE_ACCOUNT}.blob.core.windows.net/${AZURE_STORAGE_CONTAINER}/${IMAGE_NAME}.vhd
export AZURE_REGION=uksouth

base-all: base-all-aws base-all-azure

base-all-aws: PLATFORM=aws
base-all-aws: base distribute

base-all-azure: PLATFORM=azure
base-all-azure: base distribute

base: IMAGE_TYPE=openflight-cloud-base
base: setup build prepare upload

base-test: IMAGE_TYPE=openflight-cloud-base
base-test: setup build

chead: IMAGE_TYPE=openflight-cloud-chead
chead: TDL=centos7-chead.tdl
chead: KICKSTART=openflight-cloud-base-${PLATFORM}.ks
chead: setup build prepare upload

chead-test: IMAGE_TYPE=openflight-cloud-chead
chead-test: TDL=centos7-chead.tdl
chead-test: KICKSTART=openflight-cloud-base-${PLATFORM}.ks
chead-test: setup build

cnode: IMAGE_TYPE=openflight-cloud-cnode
cnode: TDL=centos7-cnode.tdl
cnode: KICKSTART=openflight-cloud-base-${PLATFORM}.ks
cnode: setup build prepare upload

cnode-test: IMAGE_TYPE=openflight-cloud-cnode
cnode-test: TDL=centos7-cnode.tdl
cnode-test: KICKSTART=openflight-cloud-base-${PLATFORM}.ks
cnode-test: setup build

setup:
	[ -d ${VM_DIR}/converted ] || mkdir -p ${VM_DIR}/converted
	[ -d ${VM_DIR}/tmp ] || mkdir -p ${VM_DIR}/tmp
	[ -f ${QEMU_IMG_BIN} ] || exit

build:
	cp -v ${TDL} ${TDL_RENDERED}
	cp -v ${KICKSTART} ${KICKSTART_RENDERED}
	sed -i -e 's,c7,${IMAGE_NAME},g' ${TDL_RENDERED}
	sed -i -e 's,%BUILD_RELEASE%,${IMAGE_VERSION},g' ${KICKSTART_RENDERED}
	echo "Building image ${IMAGE_NAME}"
	oz-install -d3 -u ${TDL_RENDERED} -x /tmp/${IMAGE_NAME}.xml \
				   -p -a ${KICKSTART_RENDERED} -c ${OZ_CFG} -t 1800

prepare:
	[ -f ${VM_DIR}/${IMAGE_NAME}.qcow2 ] || exit
	echo "Preparing ${IMAGE_NAME}"
	virt-sysprep -a ${VM_DIR}/${IMAGE_NAME}.qcow2
	echo "Sparsifying ${IMAGE_NAME}"
	virt-sparsify --tmp ${VM_DIR}/tmp \
		--compress --format qcow2 \
		${VM_DIR}/${IMAGE_NAME}.qcow2 \
		${VM_DIR}/converted/${IMAGE_NAME}.qcow2

upload:
	if [ ${PLATFORM} = "aws" ]; then ./makescripts/upload_aws.sh ; fi
	if [ ${PLATFORM} = "azure" ]; then ./makescripts/upload_azure.sh ; fi

distribute:
	if [ ${PLATFORM} = "aws" ]; then ./makescripts/distribute_aws.sh ; fi
	if [ ${PLATFORM} = "azure" ]; then ./makescripts/distribute_azure.sh ; fi

