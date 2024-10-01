#!/bin/sh

readonly BASE_IMAGE="quay.io/fedora/fedora-minimal"

for FEDORA_MAJOR_VERSION in $(seq 40 41); do
  podman run -it --rm --env IS_LOCAL_BUILD=1 -v ./scripts/:/tmp/scripts/ -v ./rpms:/tmp/rpms:Z ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} /tmp/scripts/build-nvidia-drv.sh
done
