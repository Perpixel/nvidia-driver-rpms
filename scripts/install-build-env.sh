#!/bin/sh

set -oeux pipefail

FEDORA_MAJOR_VERSION=40

# setup fedora build packages
dnf install wget git -y

# download and install rpm fusion package
wget -P /tmp/rpms \
	https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_MAJOR_VERSION}.noarch.rpm \
	https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_MAJOR_VERSION}.noarch.rpm
dnf install /tmp/rpms/*.rpm fedora-repos-archive -y

dnf install \
	rpm-build rpmspectool libappstream-glib systemd-rpm-macros rpmdevtools gcc \
	mesa-libGL-devel mesa-libEGL-devel libvdpau-devel libXxf86vm-devel libXv-devel \
	desktop-file-utils hostname gtk3-devel m4 pkgconfig mock libtirpc-devel \
	buildsys-build-rpmfusion-kerneldevpkgs-current elfutils-libelf-devel -y
