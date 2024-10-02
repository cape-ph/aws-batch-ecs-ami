#!/usr/bin/env bash
set -ex

curl -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh
bash miniconda.sh -b -f -p ~/miniconda
~/miniconda/bin/conda install -c conda-forge -y awscli=2.17.63
rm miniconda.sh
