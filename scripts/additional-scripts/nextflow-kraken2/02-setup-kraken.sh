#!/usr/bin/env bash
set -ex

# Install kraken2 from source code in GitHub
mkdir kraken2
cd kraken2
wget https://github.com/DerrickWood/kraken2/archive/refs/tags/v2.1.6.zip
unzip v2.1.6.zip
rm -rf v2.1.6.zip
./kraken2-2.1.6/install_kraken2.sh .
sudo ln -s $(pwd)/kraken2-2.1.6/kraken2 /usr/local/bin
sudo ln -s $(pwd)/kraken2-2.1.6/kraken2-build /usr/local/bin
sudo ln -s $(pwd)/kraken2-2.1.6/kraken2-inspect /usr/local/bin

# download pre-built standard kraken db
wget -O db.tar.gz https://genome-idx.s3.amazonaws.com/kraken/k2_standard_20250714.tar.gz
