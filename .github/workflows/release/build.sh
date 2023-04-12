#!/bin/bash -x

#   Copyright The containerd Authors.

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


OS=${1}
ARCH=`uname -m`
BUILD_TYPE="Release"
COMPILER=""
PACKAGE_RELEASE=""
CMAKE="cmake"
CPACK="cpack"

# Install Dependencies
if [[ ${OS} =~ "ubuntu" ]]; then
    export DEBIAN_FRONTEND="noninteractive"
    export TZ="Etc/UTC"
    apt-get update -y
    apt-get install -y libgflags-dev libcurl4-openssl-dev libssl-dev libaio-dev libnl-3-dev libnl-genl-3-dev rpm wget make g++ git dpkg-dev
    apt-get install -y uuid-dev libjson-c-dev libkmod-dev libsystemd-dev autoconf automake libtool libpci-dev nasm libzstd-dev libext2fs-dev zlib1g-dev

    DISTRO=${OS/:/1~}
    PACKAGE_RELEASE="-DPACKAGE_RELEASE=0${DISTRO}"
elif [[ ${OS} =~ "centos" ]]; then
    if [[ ${OS} == "centos:7" ]]; then
        yum install -y centos-release-scl
        yum install -y devtoolset-7-gcc-c++

        PACKAGE_RELEASE="-DPACKAGE_RELEASE=1.el7"
        COMPILER="-DCMAKE_C_COMPILER=/opt/rh/devtoolset-7/root/usr/bin/gcc -DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-7/root/usr/bin/g++"
    elif [[ ${OS} == "centos:8" ]]; then
        rm -rf /etc/yum.repos.d/* && curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo
        yum install -y gcc gcc-c++

        PACKAGE_RELEASE="-DPACKAGE_RELEASE=1.el8"
    fi

    yum install -y epel-release libaio-devel libcurl-devel openssl-devel libnl3-devel e2fsprogs-devel
    yum install -y rpm-build make git wget
    yum install --skip-broken -y libzstd-static libzstd-devel
fi

if [[ ${ARCH} == "x86_64" ]]; then
    wget https://cmake.org/files/v3.15/cmake-3.15.0-Linux-x86_64.tar.gz
    tar -zxf cmake-3.15.0-Linux-x86_64.tar.gz -C /usr/local/
    export PATH="/usr/local/cmake-3.15.0-Linux-x86_64/bin:$PATH"
else
    wget https://cmake.org/files/v3.20/cmake-3.20.6-linux-aarch64.tar.gz
    tar -zxf cmake-3.20.6-linux-aarch64.tar.gz -C /usr/local/
    export PATH="/usr/local/cmake-3.20.6-linux-aarch64/bin:$PATH"
fi

# Build
mkdir build
cd build
${CMAKE} .. -DCMAKE_BUILD_TYPE=${BUILD_TYPE} -DBUILD_TESTING=0 -DENABLE_DSA=0 -DENABLE_ISAL=0 ${PACKAGE_RELEASE} ${COMPILER}
make -j8
${CPACK}