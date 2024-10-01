#!/bin/sh

set -oeux pipefail

FEDORA_MAJOR_VERSION="$(rpm -E '%fedora')"
ARCH="$(rpm -E '%_arch')"

BUILD_PATH=/tmp/nvidia-drv
RPMBUILD_PATH=${BUILD_PATH}/rpmbuild
SOURCES_PATH=${RPMBUILD_PATH}/SOURCES
RPMS_PATH=${BUILD_PATH}/rpmbuild/RPMS/${ARCH}

if command -v dnf5 &> /dev/null; then alias dnf=dnf5; fi

build_rpm() {
  rpmbuild ${1} --bb --define "_topdir ${BUILD_PATH}/rpmbuild"
}

setup_rpm_build_env() {
  echo Setting build environment...
  mkdir -p ${BUILD_PATH}

  dnf install wget curl git tar -y
  
  # download and install rpm fusion package
  wget -P ${BUILD_PATH}/rpmfusion \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_MAJOR_VERSION}.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_MAJOR_VERSION}.noarch.rpm
  dnf install ${BUILD_PATH}/rpmfusion/*.rpm fedora-repos-archive -y

  dnf install \
    rpm-build rpmspectool libappstream-glib systemd-rpm-macros rpmdevtools gcc \
    mesa-libGL-devel mesa-libEGL-devel libvdpau-devel libXxf86vm-devel libXv-devel \
    desktop-file-utils hostname gtk3-devel m4 pkgconfig mock libtirpc-devel \
    buildsys-build-rpmfusion-kerneldevpkgs-current elfutils-libelf-devel vulkan-headers -y
}

setup_sources() {
  echo Setting up ${1} sources...
  mkdir -p ${RPMBUILD_PATH}
  ln -nsf ${BUILD_PATH}/${1} ${SOURCES_PATH}
  cd ${SOURCES_PATH}
}

pull_git_repos() {
  echo Clone required RPM Fusion projects from Github...
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
  NVIDIA_SPEC=$(ls xorg-x11-drv-nvidia*.spec)
  NVIDIA_VERSION=$(grep ^Version: ${NVIDIA_SPEC} | awk '{print $2}')
  # mkdir -p ${BUILD_PATH} && cd ${BUILD_PATH}
  curl -O https://download.nvidia.com/XFree86/Linux-${ARCH}/${NVIDIA_VERSION}/NVIDIA-Linux-${ARCH}-${NVIDIA_VERSION}.run
  build_rpm xorg-x11-drv-nvidia.spec || true
  dnf install ${RPMS_PATH}/xorg-x11-drv-nvidia-kmodsrc-*.rpm -y
}

build_kmod() {
  # nvidia-kmod
  echo Build NVIDIA-KDMOD...
  setup_sources nvidia-kmod
  mkdir -p ${RPMBUILD_PATH}/SPECS
  # ln -nsf nvidia-kmod.spec ${RPMBUILD_PATH}/SPECS/nvidia-kmod.spec
  cp ./nvidia-kmod.spec ${RPMBUILD_PATH}/SPECS/nvidia-kmod.spec
  build_rpm ${RPMBUILD_PATH}/SPECS/nvidia-kmod.spec
}

build_app() {
  name=${1}
  echo Starting ${name} rpm build...
  setup_sources ${name}
  wget https://download.nvidia.com/XFree86/${name}/${name}-${NVIDIA_VERSION}.tar.bz2
  build_rpm ${name}.spec
}

build_apps() {
  # nvidia-modprobe
  build_app nvidia-modprobe

  # nvidia-setting
  build_app nvidia-settings

  # nvidia-xconfig
  build_app nvidia-xconfig

  # nvidia-persistenced
  build_app nvidia-persistenced
}

create_archive() {
  cd ${RPMS_PATH}/
  tar -czvf nvidia-drv-${NVIDIA_VERSION}.fc${FEDORA_MAJOR_VERSION}.${ARCH}.tar.gz *
  mv nvidia-drv-*.tar.gz /tmp/rpms/
}

setup_rpm_build_env
pull_git_repos
build_driver
build_kmod
build_apps

echo Write rpms

if [ -n ${IS_LOCAL_BUILD} ]; then
  create_archive
fi
