#!/bin/sh

set -oeux pipefail

RELEASE="$(rpm -E '%fedora.%_arch')"
NVIDIA_PACKAGE_NAME="nvidia"
FEDORA_MAJOR_VERSION=40

NVIDIA_VERSION=555.52.04
NVIDIA_MAJOR_VERSION=555

BUILD_PATH=/tmp/build
SOURCES_PATH=~/rpmbuild/SOURCES
RPMS_PATH=~/rpmbuild/RPMS/x86_64

setup_sources() {
	cd ${BUILD_PATH}
	ln -nsf ${BUILD_PATH}/${1} ${SOURCES_PATH}
}

mkdir -p ${HOME}/rpmbuild
mkdir -p ${HOME}/rpmbuild/SPECS
mkdir -p ${BUILD_PATH}

cd ${BUILD_PATH}
git clone https://github.com/rpmfusion/xorg-x11-drv-nvidia.git
git clone https://github.com/rpmfusion/nvidia-kmod.git
git clone https://github.com/rpmfusion/nvidia-modprobe.git
git clone https://github.com/rpmfusion/nvidia-xconfig.git
git clone https://github.com/rpmfusion/nvidia-settings.git
git clone https://github.com/rpmfusion/nvidia-persistenced.git

# xorg-x11-drv-nvidia

setup_sources xorg-x11-drv-nvidia
cd ${SOURCES_PATH}
./nvidia-snapshot.sh
rpmbuild --bb xorg-x11-drv-nvidia.spec

dnf install ${RPMS_PATH}/xorg-x11-drv-nvidia-kmodsrc-555.52.04-1.fc40.x86_64.rpm -y

# nvidia-kmod

setup_sources nvidia-kmod
ln -nsf ${SOURCES_PATH}/nvidia-kmod.spec ~/rpmbuild/SPECS/nvidia-kmod.spec
rpmbuild --bb ${SOURCES_PATH}/nvidia-kmod.spec

# nvidia-modprobe
name=nvidia-modprobe
setup_sources ${name}
wget -P ${SOURCES_PATH} https://download.nvidia.com/XFree86/${name}/${name}-${NVIDIA_VERSION}.tar.bz2
rpmbuild --bb ${SOURCES_PATH}/${name}.spec

# nvidia-setting
name=nvidia-settings
setup_sources ${name}
wget -P ${SOURCES_PATH} https://download.nvidia.com/XFree86/${name}/${name}-${NVIDIA_VERSION}.tar.bz2
rpmbuild --bb ${SOURCES_PATH}/${name}.spec

# nvidia-xconfig
name=nvidia-xconfig
setup_sources ${name}
wget -P ${SOURCES_PATH} https://download.nvidia.com/XFree86/${name}/${name}-${NVIDIA_VERSION}.tar.bz2
rpmbuild --bb ${SOURCES_PATH}/${name}.spec

# nvidia-persistenced
name=nvidia-persistenced
setup_sources ${name}
wget -P ${SOURCES_PATH} https://download.nvidia.com/XFree86/${name}/${name}-${NVIDIA_VERSION}.tar.bz2
rpmbuild --bb ${SOURCES_PATH}/${name}.spec

mv ~/rpmbuild/RPMS/* /tmp/rpms/
ls -la /tmp/rpms/
