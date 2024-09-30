#!/usr/bin/env bash
set -ex

# install micromamba
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/2.0.0 | tar -xvj bin/micromamba
sudo mv bin/micromamba /usr/local/bin
rm -rf bin
/usr/local/bin/micromamba shell init -s bash

# # install bactopia
bash -l -c 'micromamba create -n bactopia -c conda-forge -c bioconda bactopia=3.0.1 -y'
echo "micromamba activate bactopia" >>~/.bashrc
