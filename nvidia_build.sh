#!/bin/sh

readonly BUILD_PATH="./build/"
readonly SCRIPT_PATH="./scripts"
readonly BASE_IMAGE="registry.fedoraproject.org/fedora"

for FEDORA_MAJOR_VERSION in $(seq 40 40); do
  podman build --build-arg=BASE_IMAGE=${BASE_IMAGE} --build-arg=FEDORA_MAJOR_VERSION=${FEDORA_MAJOR_VERSION} -t nvidia-driver-build -f Containerfile
  podman run -it --rm --env FEDORA_MAJOR_VERSION=${FEDORA_MAJOR_VERSION} -v ./scripts/:/tmp/scripts/ -v ./rpms:/tmp/rpms:Z nvidia-driver-build /tmp/scripts/build.sh
  #podman run -it --rm --env FEDORA_MAJOR_VERSION=${FEDORA_MAJOR_VERSION} -v ./scripts/:/tmp/scripts/ -v ./rpms:/tmp/rpms:Z nvidia-driver-build /tmp/scripts/test.sh
done

# publish to github
