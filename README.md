# Packer Based Amazon ECS AMI

This is heavily based on the official [AWS provided packer recipes](https://github.com/aws/amazon-ecs-ami)

## Optional EFS host mounts

The AMI includes an opt-in systemd service for mounting EFS resources before
ECS starts. It is intended for Batch compute environments with a declared host
capability, such as `taxonomic-reference-data`. General-purpose Batch hosts
can omit the configuration and the service becomes a no-op.

The runtime or instance bootstrap provides the configuration at:

```text
/etc/ecs/efs-mounts.json
```

A capability host can require the configuration by also providing:

```text
/etc/ecs/efs-mounter.env
```

with:

```text
ECS_EFS_MOUNTER_REQUIRED=true
```

General-purpose hosts omit this file and the mounter remains a no-op. A
required host fails the ECS dependency if its mount configuration is missing.

The configuration supports multiple resources and does not require an AMI
rebuild when the physical resource changes:

```json
{
  "version": 1,
  "mounts": [
    {
      "name": "reference-data",
      "fileSystemId": "fs-0123456789abcdef0",
      "accessPointId": "fsap-0123456789abcdef0",
      "mountPath": "/mnt/cape/resources/reference-data",
      "readOnly": true,
      "tls": true,
      "iam": true
    }
  ]
}
```

The filesystem and access-point values above are placeholders. Deployment
configuration must provide the current values. Resource IDs must not be baked
into the image or pipeline fixtures.

The service is pulled in by `ecs.service` and runs after network readiness. A
configured resource is mounted with `amazon-efs-utils`, verified as a mount, and
then made available to ECS. A mount failure fails the service dependency so the
host does not silently present an empty directory as a usable resource. The
configuration must be present before ECS starts. Late configuration changes can
be checked with:

```bash
sudo /usr/local/sbin/ecs-efs-mounter validate
sudo systemctl restart ecs-efs-mounter.service
```

The service also supports `unmount` for controlled host shutdown. The AMI does
not decide which Batch queue receives a workload. CAPE or another deployment
layer supplies the host capability configuration and routes workloads to
compatible compute environments.
