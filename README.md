# Building Cloudware images

Notes on building and using Cloudware images on various platforms

## Prerequisites

- Standard Alces Libvirt host setup (including libguestfs-tools)
- Large amount of disk space
- AWS/Azure command-line tools installed
- Binary of qemu-img (>version that comes with CentOS [1.5.3]) which will need to be set as `QEMU_IMG_BIN` in `Makefile` (if wanting to do Azure stuff, most likely a build from source - https://www.qemu.org/download/#source)
  - On a CentOS 7 system the compilation requires the group `"Development Tools"` and package `gtk2-devel` installed to be able to compile v2+ of qemu-img (v3.1.0 has been tested with the Azure deployment method)

## General usage

The `Makefile` contains all build steps to build, prepare and upload an image to each available Cloud provider. Images are built using Oz and the approrpriate kickstart file for the provider. 

### Configuration

There are a few notable config settings, including:

- `PLATFORM` - The platform to build an image for, e.g. `aws` or `azure`
- `IMAGE_VERSION` - Set the image version to create
- `VM_DIR` - Set the VM dir, this should have enough space to create the image 

## Build

To assist the creation and distribution of the images, a wrapper script for building all platforms can be executed as:

```
bash build_all.sh
```

This will (currently) build the image for AWS and Azure, upload to the respective cloud platforms and then distribute around all of the regions.

## AWS

### Configuration

In order to create an AWS image, the client running Cloudware should meet the following prerequisites:

- AWS command-line tools installed
- AWS credentials configured
- S3 bucket with folder for images to be stored in
- AWS IAM role for VM Import/Export created

There are also a couple of config options in `Makefile`, which are important to set correctly:

- `AWS_BUCKET` - The S3 bucket name the image(s) are to be stored in
- `AWS_BUCKET_DIR` - The folder within the S3 bucket
- `AWS_REGION` - The region the S3 bucket is created in, and also the destination region for the created image

### Building an image

Once the configuration and prerequisites are met - creating, preparing and uploading an image is as simple as running:

```bash
make image PLATFORM=aws
```

### Post-build tasks

The final stage of the build process will output some JSON, displaying the VM import task ID, and the resulting AMI ID for the given region:

```json
{
    "Status": "active",
    "LicenseType": "BYOL",
    "Description": "alces-cloudware-base-2018.2.1-aws",
    "Platform": "Linux",
    "Architecture": "x86_64",
    "SnapshotDetails": [
        {
            "UserBucket": {
                "S3Bucket": "alces-cloudware",
                "S3Key": "images/alces-cloudware-base-2018.2.1-aws.raw"
            },
            "DiskImageSize": 0.0,
            "Format": "RAW"
        }
    ],
    "Progress": "2",
    "StatusMessage": "pending",
    "ImportTaskId": "import-ami-fgrxv97s"
}
```

The new AMI in the above example will be `ami-fgrxv97s`. You can then copy this AMI round to other regions if required. 

## Azure

### Configuration

In order to create an Azure image, the client running Cloudware should meet the following prerequisites:

- Azure command-line tools installed
- Azure credentials configured
- Resource Group with storage account created
- Storage container created inside the storage account

There are also a couple of config options in `Makefile`, which are important to set correctly:

- `AZURE_STORAGE_ACCOUNT` - The name of the storage account
- `AZURE_STORAGE_CONTAINER` - Name of the storage container created within the storage account
- `AZURE_RESOURCE_GROUP` - The name of the resource group containing the storage account

### Building an image

Once the configuration and prerequisites are met - creating, preparing and uploading an image is as simple as running:

```bash
make image PLATFORM=azure
```
