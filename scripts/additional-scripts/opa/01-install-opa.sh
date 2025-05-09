#!/usr/bin/env bash
set -ex

AMI_SCRIPTS=/tmp/additional-scripts/"${AMI_PREFIX}"

OPA_VERSION=v1.4.2
LOCAL_BIN=/usr/local/bin
OPA_ETC_PATH=/etc/opa

sudo curl -L -o ${LOCAL_BIN}/opa https://github.com/open-policy-agent/opa/releases/download/${OPA_VERSION}/opa_linux_amd64
sudo chmod 755 ${LOCAL_BIN}/opa

# TODO: get the service file and config correct

# copy default OPA config
sudo mkdir -p "${OPA_ETC_PATH}/config"
sudo cp "${AMI_SCRIPTS}"/opa-config.yaml "${OPA_ETC_PATH}"/config/opa-config.yaml

# copy opa service file
sudo mkdir -p "${OPA_ETC_PATH}/systemd"
sudo cp "${AMI_SCRIPTS}"/opa.service "${OPA_ETC_PATH}"/systemd/opa.service
sudo ln -s "${OPA_ETC_PATH}"/systemd/opa.service /etc/systemd/system/opa.service

sudo systemctl daemon-reload
sudo systemctl enable --now opa.service
sudo systemctl start opa.service
