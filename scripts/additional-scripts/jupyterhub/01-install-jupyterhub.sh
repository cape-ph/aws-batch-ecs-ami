#!/usr/bin/env bash
set -ex

AMI_SCRIPTS=/tmp/additional-scripts/"${AMI_PREFIX}"
JUPYTERHUB_PATH=/opt/jupyterhub

sudo mkdir -p "${JUPYTERHUB_PATH}"

sudo tee ${JUPYTERHUB_PATH}/env <<EOF
JUPYTERHUB_CRYPT_KEY=$(openssl rand -hex 32)
PATH=/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/jupyterhub/bin
EOF

#  add jupyterhub groups
sudo groupadd --force jupyterhub-users

# install http proxy
sudo npm install -g configurable-http-proxy@4

# create jupyterhub environment
sudo python3 -m venv "${JUPYTERHUB_PATH}"

# install jupyterhub into our environment
sudo "${JUPYTERHUB_PATH}"/bin/pip install jupyterhub jupyterlab notebook oauthenticator

# install AWS tooling
sudo "${JUPYTERHUB_PATH}"/bin/pip install boto3

# copy default jupyterhub config
sudo mkdir -p "${JUPYTERHUB_PATH}"/etc/jupyterhub
sudo cp "${AMI_SCRIPTS}"/jupyterhub_config.py "${JUPYTERHUB_PATH}"/etc/jupyterhub/jupyterhub_config.py

# copy jupyterhub service file
sudo mkdir -p "${JUPYTERHUB_PATH}"/etc/systemd
sudo cp "${AMI_SCRIPTS}"/jupyterhub.service "${JUPYTERHUB_PATH}"/etc/systemd/jupyterhub.service
sudo ln -s "${JUPYTERHUB_PATH}"/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service
sudo systemctl daemon-reload
sudo systemctl enable --now jupyterhub.service
