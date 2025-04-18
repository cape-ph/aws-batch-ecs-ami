packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  packages = "amazon-efs-utils amazon-ssm-agent amazon-ec2-net-utils acpid"
}

variable "additional_packages" {
  type        = string
  description = "Additional packages to be installed with yum/dnf"
  default     = ""
}

variable "ami_name_prefix" {
  type        = string
  description = "Outputted AMI name prefix."
  default     = "unofficial-amzn2023-ami-ecs"
}

variable "ami_version" {
  type        = string
  description = "Outputted AMI version."
}

variable "region" {
  type        = string
  description = "Region to build the AMI in."
}

variable "block_device_size_gb" {
  type        = number
  description = "Size of the root block device."
  default     = 30
}

variable "ecs_agent_version" {
  type        = string
  description = "ECS agent version to build AMI with."
  default     = "1.84.0"
}

variable "ecs_init_rev" {
  type        = string
  description = "ecs-init package version rev"
  default     = "1"
}

variable "docker_version" {
  type        = string
  description = "Docker version to build AL2023 AMI with."
  default     = "25.0.3"
}

variable "containerd_version" {
  type        = string
  description = "Containerd version to build AL2023 AMI with."
  default     = "1.7.11"
}

variable "runc_version" {
  type        = string
  description = "Runc version to build AL2023 AMI with."
  default     = "1.1.11"
}

variable "exec_ssm_version" {
  type        = string
  description = "SSM binary version to build ECS exec support with."
  default     = "3.2.2303.0"
}

variable "source_ami" {
  type        = string
  description = "Amazon Linux 2023 source AMI to build from."
}

variable "source_ami_arm" {
  type        = string
  description = "Amazon Linux 2023 ARM source AMI to build from."
}

variable "distribution_release" {
  type        = string
  description = "Amazon Linux 2023 distribution release."
}

variable "kernel_version" {
  type        = string
  description = "Amazon Linux 2023 kernel version."
}

variable "kernel_version_arm" {
  type        = string
  description = "Amazon Linux 2023 ARM kernel version."
}

variable "air_gapped" {
  type        = string
  description = "If this build is for an air-gapped region, set to 'true'"
  default     = ""
}

variable "ecs_init_url" {
  type        = string
  description = "Specify a particular ECS init URL for AL2023 to install. If empty it will use the standard path."
  default     = ""
}

variable "ecs_init_local_override" {
  type        = string
  description = "Specify a local init rpm under /additional-packages to be used for building AL2 and AL2023 AMIs. If empty it will use ecs_init_url if specified, otherwise the standard path"
  default     = ""
}

variable "general_purpose_instance_types" {
  type        = list(string)
  description = "List of available in-region instance types for general-purpose platform"
  default     = ["c5.large"]
}

variable "gpu_instance_types" {
  type        = list(string)
  description = "List of available in-region instance types for GPU platform"
  default     = ["c5.4xlarge"]
}

variable "arm_instance_types" {
  type        = list(string)
  description = "List of available in-region instance types for ARM platform"
  default     = ["m6g.xlarge"]
}

variable "inf_instance_types" {
  type        = list(string)
  description = "List of available in-region instance types for INF platform"
  default     = ["inf1.xlarge"]
}

variable "neu_instance_types" {
  type        = list(string)
  description = "List of available in-region instance types for NEU platform"
  default     = ["inf1.xlarge"]
}

variable "managed_daemon_base_url" {
  type        = string
  description = "Base URL (minus file name) to download managed daemons from."
  default     = ""
}

variable "ebs_csi_driver_version" {
  type        = string
  description = "EBS CSI driver version to build AMI with."
  default     = ""
}
