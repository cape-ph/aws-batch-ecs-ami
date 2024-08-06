#!/usr/bin/env bash
set -ex

# download nextflow and build it
curl -s https://get.nextflow.io | bash
# make the created binary executable
chmod +x nextflow
# move it into place
sudo mv nextflow /usr/local/bin
