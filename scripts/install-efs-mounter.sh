#!/usr/bin/env bash
set -euo pipefail

sudo install -D -m 0755 \
    /tmp/ecs-efs-mounter.sh \
    /usr/local/sbin/ecs-efs-mounter
sudo install -D -m 0644 \
    /tmp/ecs-efs-mounter.service \
    /etc/systemd/system/ecs-efs-mounter.service
sudo install -D -m 0644 \
    /tmp/10-ecs-efs-mounter.conf \
    /etc/systemd/system/ecs.service.d/10-ecs-efs-mounter.conf
sudo install -d -m 0755 /etc/ecs
sudo systemctl daemon-reload
