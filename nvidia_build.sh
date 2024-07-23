#!/bin/sh

set -oeux pipefail

readonly BUILD_PATH="./build/"
readonly SCRIPT_PATH="./scripts"
readonly BASE_IMAGE="registry.fedoraproject.org/fedora"
readonly FEDORA_MAJOR_VERSION="40"

podman build --build-arg=BASE_IMAGE=${BASE_IMAGE} --build-arg=FEDORA_MAJOR_VERSION=${FEDORA_MAJOR_VERSION} -t nvidia-driver-build -f Containerfile
podman run -it --rm -v ./scripts/:/tmp/scripts/ -v ./rpms:/tmp/rpms:Z nvidia-driver-build /tmp/scripts/build.sh

# publish to github
