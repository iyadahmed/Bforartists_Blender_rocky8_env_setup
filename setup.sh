#!/bin/bash

set -e

shallow_clone_if_does_not_exist() {
    URL="$1"
    FOLDER="$2"
    if [ ! -d "$FOLDER" ]; then
        git clone --depth=1 "$URL" "$FOLDER"
    fi
}

# Install needed packages
dnf -y install sudo
sudo dnf -y update
sudo dnf -y install wget
sudo dnf -y install scl-utils gcc-toolset-11 bash python3 libSM
sudo dnf -y install pulseaudio-libs-devel
sudo dnf -y --enablerepo=powertools install libstdc++-static
sudo dnf -y install gcc gcc-c++ git subversion make cmake mesa-libGL-devel mesa-libEGL-devel libX11-devel libXxf86vm-devel libXi-devel libXcursor-devel libXrandr-devel libXinerama-devel
sudo dnf -y install wayland-devel wayland-protocols-devel libxkbcommon-devel dbus-devel kernel-headers

# Compile and install Jack audio library from source
# shallow_clone_if_does_not_exist https://github.com/jackaudio/jack2.git jack2
# pushd jack2
# ./waf configure
# ./waf install
# popd

# Install local CUDA repo
sudo dnf -y localinstall ./cuda-repo-rhel8-12-2-local-12.2.0_535.54.03-1.x86_64.rpm
sudo dnf -y clean all
sudo dnf -y install cuda-toolkit-12-2

# Install Optix
sudo dnf -y install tar
chmod +x ./NVIDIA-OptiX-SDK-7.3.0-linux64-x86_64.sh
sudo ./NVIDIA-OptiX-SDK-7.3.0-linux64-x86_64.sh --prefix=/usr/local --include-subdir --skip-license

# Install HIP compiler prerequisites
sudo dnf -y install kernel-headers kernel-devel
wget -nc https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo dnf -y localinstall epel-release-latest-8.noarch.rpm
sudo crb enable

# Install ROCm repository
sudo chmod +x ./internal_scripts/install_rocm_repo.sh
sudo ./internal_scripts/install_rocm_repo.sh

# This is the ROCm HIP SDK (which has the hipcc compiler and needed libraries)
# powertools repo is needed for the "perl-File-BaseDir" package which is in turn needed by the "hip-devel" package
sudo dnf -y --enablerepo=powertools install rocm-hip-sdk

# ROCm hip-sdk-post install
sudo chmod +x ./internal_scripts/rocm_post_install.sh
sudo ./internal_scripts/rocm_post_install.sh

# Enable GCC11 toolset permanently, needed to compile Bforartists/Blender
sudo tee --append ~/.bashrc <<EOF
source scl_source enable gcc-toolset-11
EOF
