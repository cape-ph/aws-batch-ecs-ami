#!/usr/bin/env bash
set -ex

cd $HOME
sudo yum install -y bzip2 wget
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -f -p $HOME/miniconda
$HOME/miniconda/bin/conda install -c conda-forge --override-channels -y awscli
rm Miniconda3-latest-Linux-x86_64.sh
