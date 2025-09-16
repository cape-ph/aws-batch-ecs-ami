# Packer Based Amazon ECS AMI

This is heavily based on the official [AWS provided packer recipes](https://github.com/aws/amazon-ecs-ami)

## Basic Usage
1. Identify the target you are building. There are a number of them supported 
   here (e.g. `build-cape-frontend`, `build-jupyterhub`, `build`).
1. Ensure you have the tools required (e.g. `packer`)
1. Deregister any previously existing AMI in AWS that have the name of the
   target you are building (failure to do this will result in an error that 
   the AMI already exists).
1. Build your target. If all succeeds the AMI will be pushed to AWS for use.

## Available Targets
* `build` - The baseline AMI for CAPE VMs needing an Amazon Linux 2023 
   environment.
* `build-awsbatch` - The AMI used for AWS Batch compute environments.
* `build-nextflow` - The AMI used for Nextflow orchestration environments.
* `build-nextflow-kraken2` - The AMI used for Nextflow orchestration 
   environments that also require the `kraken2` tool.
* `build-jupyterhub` - The AMI for our jupyterhub environment.
* `build-opa` - The AMI for instances running OPA.
* `build-cape-frontend` - The AMI for the latest CAPE frontend.
