#!/usr/bin/env bash
set -ex

# make sure docker plugin directory exists
sudo mkdir -p /usr/libexec/docker/cli-plugins
# download docker compose plugin
sudo curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/libexec/docker/cli-plugins/docker-compose
# make docker compose executable
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
