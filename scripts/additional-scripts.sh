#!/usr/bin/env bash
set -ex

ADDITIONAL_SCRIPTS_PREFIX="${ADDITIONAL_SCRIPTS_PREFIX:-${AMI_PREFIX}}"
AMI_SCRIPTS=/tmp/additional-scripts/"${ADDITIONAL_SCRIPTS_PREFIX}"

if [ -d "${AMI_SCRIPTS}" ]; then
    for f in $(find "${AMI_SCRIPTS}" -maxdepth 1 -type f -name "*.sh" | sort -g); do
        echo "Executing ${f}"
        bash "$f"
    done
fi
