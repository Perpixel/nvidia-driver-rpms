#!/bin/sh

set -oeux pipefail

RELEASE="$(rpm -E '%fedora.%_arch')"
PACKAGE="RpmFusionXorgX11DrvNvidia"
SOURCES_PATH="/tmp/rpmbuild/SOURCES"

mkdir -p /tmp/rpmbuild

git clone https://github.com/rpmfusion/xorg-x11-drv-nvidia.git ~/source/${PACKAGE}

ln -nsf ~/source/${PACKAGE} ${SOURCES_PATH}
cd /tmp/rpmbuild/SOURCES
./nvidia-snapshot.sh
NVIDIA_SPEC=$(ls xorg-x11-drv-nvidia*.spec)
NVIDIA_VERSION=$(grep ^Version: ${NVIDIA_SPEC} | awk '{print $2}')
rpmbuild xorg-x11-drv-nvidia.spec --bb --define "_topdir /tmp/rpmbuild"
