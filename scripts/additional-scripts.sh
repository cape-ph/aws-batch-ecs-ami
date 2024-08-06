#!/usr/bin/env bash
set -ex

AMI_SCRIPTS=/tmp/additional-scripts/"${AMI_PREFIX}"

if [ -d "${AMI_SCRIPTS}" ]; then
    for f in $(find "${AMI_SCRIPTS}" -maxdepth 1 -type f -name "*.sh" | sort -g); do
        echo "Executing ${f}"
        bash "$f"
    done
fi
