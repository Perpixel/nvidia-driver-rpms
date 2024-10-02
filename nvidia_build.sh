#!/bin/sh

readonly BASE_IMAGE="quay.io/fedora/fedora-minimal"

for FEDORA_MAJOR_VERSION in $(seq 40 41); do
  podman run -it --rm -v ./scripts:/tmp/scripts:z -v ./rpms:/tmp/rpms:z ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} /tmp/scripts/build-nvidia-drv.sh
done
