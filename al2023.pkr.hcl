locals {
  ami_name = "${var.ami_name_prefix}-hvm-2023.0.${var.ami_version}${var.kernel_version}-x86_64"
}

source "amazon-ebs" "al2023" {
  ami_name        = "${local.ami_name}"
  ami_description = "Amazon Linux AMI 2023.0.${var.ami_version} x86_64 ECS HVM EBS"
  instance_type   = var.general_purpose_instance_types[0]
  launch_block_device_mappings {
    volume_size           = var.block_device_size_gb
    delete_on_termination = true
    volume_type           = "gp3"
    device_name           = "/dev/xvda"
  }
  region = var.region
  source_ami_filter {
    filters = {
      name = "${var.source_ami}"
    }
    owners             = ["amazon"]
    most_recent        = true
    include_deprecated = true
  }
  ssh_interface = "public_ip"
  ssh_username  = "ec2-user"
  tags = {
    os_version          = "Amazon Linux 2023"
    source_image_name   = "{{ .SourceAMIName }}"
    ecs_runtime_version = "Docker version ${var.docker_version}"
    ecs_agent_version   = "${var.ecs_agent_version}"
    ami_type            = "al2023"
    ami_version         = "2023.0.${var.ami_version}"
  }
}

build {
  sources = [
    "source.amazon-ebs.al2023",
  ]

  provisioner "file" {
    source      = "files/90_ecs.cfg.amzn2"
    destination = "/tmp/90_ecs.cfg"
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "sudo mv /tmp/90_ecs.cfg /etc/cloud/cloud.cfg.d/90_ecs.cfg",
      "sudo chown root:root /etc/cloud/cloud.cfg.d/90_ecs.cfg"
    ]
  }

  provisioner "shell" {
    script = "scripts/setup-motd.sh"
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "mkdir /tmp/additional-packages",
      "mkdir /tmp/additional-scripts"
    ]
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "sudo dnf update -y --releasever=${var.distribution_release}"
    ]
  }

  provisioner "file" {
    source      = "additional-packages/"
    destination = "/tmp/additional-packages"
  }

  provisioner "file" {
    source      = "scripts/additional-scripts/"
    destination = "/tmp/additional-scripts"
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "sudo dnf install -y ${local.packages} ${var.additional_packages}",
      "sudo dnf swap -y gnupg2-minimal gnupg2-full"
    ]
  }

  provisioner "shell" {
    script = "scripts/setup-ecs-config-dir.sh"
  }

  provisioner "shell" {
    script = "scripts/install-docker.sh"
    environment_vars = [
      "DOCKER_VERSION=${var.docker_version}",
      "CONTAINERD_VERSION=${var.containerd_version}",
      "RUNC_VERSION=${var.runc_version}",
      "AIR_GAPPED=${var.air_gapped}"
    ]
  }

  provisioner "shell" {
    script = "scripts/install-ecs-init.sh"
    environment_vars = [
      "REGION=${var.region}",
      "AGENT_VERSION=${var.ecs_agent_version}",
      "INIT_REV=${var.ecs_init_rev}",
      "AL_NAME=amzn2023",
      "ECS_INIT_URL=${var.ecs_init_url}",
      "AIR_GAPPED=${var.air_gapped}",
      "ECS_INIT_LOCAL_OVERRIDE=${var.ecs_init_local_override}"
    ]
  }

  provisioner "shell" {
    script = "scripts/install-managed-daemons.sh"
    environment_vars = [
      "REGION=${var.region}",
      "AGENT_VERSION=${var.ecs_agent_version}",
      "EBS_CSI_DRIVER_VERSION=${var.ebs_csi_driver_version}",
      "AIR_GAPPED=${var.air_gapped}",
      "MANAGED_DAEMON_BASE_URL=${var.managed_daemon_base_url}"
    ]
  }

  provisioner "shell" {
    script = "scripts/append-efs-client-info.sh"
  }

  provisioner "shell" {
    script = "scripts/install-additional-packages.sh"
  }

  provisioner "shell" {
    script = "scripts/additional-scripts.sh"
    environment_vars = [
      "AMI_PREFIX=${var.ami_name_prefix}",
    ]
  }

  ### exec

  provisioner "file" {
    source      = "files/amazon-ssm-agent.gpg"
    destination = "/tmp/amazon-ssm-agent.gpg"
  }

  provisioner "shell" {
    script = "scripts/install-exec-dependencies.sh"
    environment_vars = [
      "REGION=${var.region}",
      "EXEC_SSM_VERSION=${var.exec_ssm_version}",
      "AIR_GAPPED=${var.air_gapped}"
    ]
  }

  ### reboot worker instance to install kernel update. enable-ecs-agent-inferentia-support needs
  ### new kernel (if there is) to be installed.
  provisioner "shell" {
    inline_shebang    = "/bin/sh -ex"
    expect_disconnect = "true"
    inline = [
      "sudo reboot"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "AMI_TYPE=${source.name}"
    ]
    pause_before        = "10s" # pause for starting the reboot
    start_retry_timeout = "40s" # wait before start retry
    max_retries         = 3
    script              = "scripts/enable-ecs-agent-inferentia-support.sh"
  }

  provisioner "shell" {
    inline_shebang = "/bin/sh -ex"
    inline = [
      "sudo usermod -a -G docker ec2-user"
    ]
  }

  provisioner "shell" {
    script = "scripts/enable-services.sh"
  }

  provisioner "shell" {
    script = "scripts/install-service-connect-appnet.sh"
  }

  provisioner "shell" {
    script = "scripts/cleanup.sh"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}
