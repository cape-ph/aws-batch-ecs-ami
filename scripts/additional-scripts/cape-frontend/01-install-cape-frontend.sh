#!/usr/bin/env bash
set -ex

AMI_SCRIPTS=/tmp/additional-scripts/"${AMI_PREFIX}"
CAPE_FRONTEND_PATH=/opt/cape-frontend

sudo mkdir -p "${CAPE_FRONTEND_PATH}"

# Clone CAPE Frontend repo
sudo git clone --depth 1 https://github.com/cape-ph/cape-frontend.git ${CAPE_FRONTEND_PATH}/repo

# Create base environment file
sudo tee ${CAPE_FRONTEND_PATH}/env <<EOF
NODE_ENV=production
HOST=0.0.0.0
EOF

cd /opt/cape-frontend/repo

# install dependencies
sudo npm install --force

# build web app
sudo npm run build

# copy cape-frontend service file
sudo mkdir -p "${CAPE_FRONTEND_PATH}"/etc/systemd
sudo cp "${AMI_SCRIPTS}"/cape-frontend.service "${CAPE_FRONTEND_PATH}"/etc/systemd/cape-frontend.service
sudo ln -s "${CAPE_FRONTEND_PATH}"/etc/systemd/cape-frontend.service /etc/systemd/system/cape-frontend.service
sudo systemctl daemon-reload
sudo systemctl enable --now cape-frontend.service
