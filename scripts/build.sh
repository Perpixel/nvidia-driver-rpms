#!/bin/sh

set -oeux pipefail

RELEASE="$(rpm -E '%fedora.%_arch')"

BUILD_PATH=/tmp/build
SOURCES_PATH=~/rpmbuild/SOURCES
RPMS_PATH=~/rpmbuild/RPMS/x86_64

setup_sources() {
	cd ${BUILD_PATH}
	ln -nsf ${BUILD_PATH}/${1} ${SOURCES_PATH}
}

create_build_dirs() {
	mkdir -p ${HOME}/rpmbuild
	mkdir -p ${HOME}/rpmbuild/SPECS
	mkdir -p ${BUILD_PATH}
}

pull_git_repos() {
	cd ${BUILD_PATH}
	git clone https://github.com/rpmfusion/xorg-x11-drv-nvidia.git
	git clone https://github.com/rpmfusion/nvidia-kmod.git
	git clone https://github.com/rpmfusion/nvidia-modprobe.git
	git clone https://github.com/rpmfusion/nvidia-xconfig.git
	git clone https://github.com/rpmfusion/nvidia-settings.git
	git clone https://github.com/rpmfusion/nvidia-persistenced.git
}

build_driver() {
	# xorg-x11-drv-nvidia
	setup_sources xorg-x11-drv-nvidia
	cd ${SOURCES_PATH}
	./nvidia-snapshot.sh
	NVIDIA_SPEC=$(ls xorg-x11-drv-nvidia*.spec)
	NVIDIA_VERSION=$(grep ^Version: ${NVIDIA_SPEC} | awk '{print $2}')
	rpmbuild --bb xorg-x11-drv-nvidia.spec
	dnf install ${RPMS_PATH}/xorg-x11-drv-nvidia-kmodsrc-*.rpm -y
}

build_kmod() {
	# nvidia-kmod
	setup_sources nvidia-kmod
	ln -nsf ${SOURCES_PATH}/nvidia-kmod.spec ~/rpmbuild/SPECS/nvidia-kmod.spec
	rpmbuild --bb ${SOURCES_PATH}/nvidia-kmod.spec
}

build_apps() {
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
}

create_archive() {
	cd ${RPMS_PATH}/
	tar -czvf nvidia-drv-${NVIDIA_VERSION}.tar.gz *
	mv nvidia-drv-*.tar.gz /tmp/rpms/
}

create_build_dirs
pull_git_repos
build_driver
build_kmod
build_apps
create_archive
