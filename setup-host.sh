#!/bin/bash

if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit
fi

function install_build_deps {
        apt-get install -y libboost-dev:armhf libpng-dev:armhf zlib1g-dev:armhf \
	libjpeg-dev:armhf swig:armhf libzbar0:armhf libglib2.0-dev:armhf libx11-dev:armhf \
	libqt4-dev:armhf libbson-dev:armhf qt4-qmake:armhf qt4-linguist-tools:armhf \
	libqt4-dev:armhf libqt4-dev-bin:armhf libcv-dev:armhf libopencv-contrib-dev:armhf
}

dpkg --add-architecture armhf
apt-get update && apt-get upgrade -y

apt-get install -y crossbuild-essential-armhf bc wget cmake checkinstall qemu-user-static

install_build_deps
apt --fix-broken install
install_build_deps

ln -sf /usr/lib/arm-linux-gnueabihf/qt4/bin/qmake /usr/bin/qmake
