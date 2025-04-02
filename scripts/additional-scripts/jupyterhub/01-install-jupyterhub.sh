#!/usr/bin/env bash
set -ex

AMI_SCRIPTS=/tmp/additional-scripts/"${AMI_PREFIX}"
JUPYTERHUB_PATH=/opt/jupyterhub

# install http proxy
sudo npm install -g configurable-http-proxy

# create jupyterhub environment
sudo python3 -m venv "${JUPYTERHUB_PATH}"

# install jupyterhub into our environment
sudo "${JUPYTERHUB_PATH}"/bin/pip install jupyterhub jupyterlab notebook

# copy default jupyterhub config
sudo mkdir -p "${JUPYTERHUB_PATH}"/etc/jupyterhub
sudo cp "${AMI_SCRIPTS}"/jupyterhub_config.py "${JUPYTERHUB_PATH}"/etc/jupyterhub/jupyterhub_config.py

# copy jupyterhub service file
sudo mkdir -p "${JUPYTERHUB_PATH}"/etc/systemd
sudo cp "${AMI_SCRIPTS}"/jupyterhub.service "${JUPYTERHUB_PATH}"/etc/systemd/jupyterhub.service
sudo ln -s "${JUPYTERHUB_PATH}"/etc/systemd/jupyterhub.service /etc/systemd/system/jupyterhub.service
sudo systemctl daemon-reload
sudo systemctl enable --now jupyterhub.service
