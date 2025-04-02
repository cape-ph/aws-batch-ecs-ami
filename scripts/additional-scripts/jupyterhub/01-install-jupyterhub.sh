#!/usr/bin/env bash
set -ex

# install http proxy
sudo npm install -g configurable-http-proxy

# create jupyterhub environment
sudo python3 -m venv /opt/jupyterhub_env

# install jupyterhub into our environment
sudo /opt/jupyterhub_env/bin/pip install jupyterhub jupyterlab notebook
