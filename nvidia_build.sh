#!/bin/bash

readonly BASE_IMAGE="quay.io/fedora/fedora"

for FEDORA_MAJOR_VERSION in $(seq 40 41); do
  podman run -it --rm --env BUILD=true -v ./scripts:/tmp/scripts:z -v ./rpms:/tmp/nvidia-drv/rpmbuild/RPMS:z ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} bash -c "/tmp/scripts/build-nvidia-drv.sh"
  ls -la ./rpms/x86_64
done
