#!/bin/bash

set -e

EMDEBIAN_REPOS="deb http://emdebian.org/tools/debian/ jessie main"

if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit
fi

apt-get update
apt-get install curl -y

if ! grep -Fxq "$EMDEBIAN_REPOS" /etc/apt/sources.list
then
	echo $EMDEBIAN_REPOS >> /etc/apt/sources.list
fi

curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | sudo apt-key add -

dpkg --add-architecture armhf
apt-get update && apt-get upgrade -y

apt-get install -y \
        crossbuild-essential-armhf bc wget \
        binutils-arm-linux-gnueabihf gcc-arm-linux-gnueabihf qemu-user-static cmake checkinstall

apt-get install -y \
        libqt4-dev:armhf libboost-dev:armhf libpng-dev:armhf zlib1g-dev:armhf libssl-dev:armhf \
        libjpeg-dev:armhf swig:armhf libzbar0:armhf libglib2.0-dev:armhf libmagick++-6-headers \
	libx11-dev:armhf

mkdir setup-tmp
cd setup-tmp

wget "http://ftp.debian.org/debian/pool/main/libb/libbson/libbson-dev_1.6.3-1_armhf.deb" \
     "http://ftp.debian.org/debian/pool/main/libb/libbson/libbson-1.0-0_1.6.3-1_armhf.deb" \
     "http://security.debian.org/debian-security/pool/updates/main/i/imagemagick/libmagick++-6.q16-dev_6.8.9.9-5+deb8u9_armhf.deb" \
     "http://ftp.debian.org/debian/pool/main/z/zbar/libzbar-dev_0.10+doc-10_armhf.deb" \
     "http://ftp.debian.org/debian/pool/main/q/qt4-x11/libqt4-dev-bin_4.8.7+dfsg-11_armhf.deb" \
     "http://ftp.debian.org/debian/pool/main/q/qt4-x11/qt4-qmake_4.8.6+git64-g5dc8b2b+dfsg-3+deb8u1_armhf.deb" \
     "http://ftp.debian.org/debian/pool/main/q/qt4-x11/qt4-linguist-tools_4.8.6+git64-g5dc8b2b+dfsg-3+deb8u1_armhf.deb" \
     "http://ftp.debian.org/debian/pool/main/o/openssl/libssl-dev_1.0.1t-1+deb8u6_armhf.deb" \
     "http://ftp.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u6_armhf.deb"

dpkg -i --force-depends libbson-1.0-0_1.6.3-1_armhf.deb libbson-dev_1.6.3-1_armhf.deb libmagick++-6.q16-dev_6.8.9.9-5+deb8u9_armhf.deb \
	libzbar-dev_0.10+doc-10_armhf.deb libqt4-dev-bin_4.8.7+dfsg-11_armhf.deb qt4-qmake_4.8.6+git64-g5dc8b2b+dfsg-3+deb8u1_armhf.deb \
	qt4-linguist-tools_4.8.6+git64-g5dc8b2b+dfsg-3+deb8u1_armhf.deb libssl-dev_1.0.1t-1+deb8u6_armhf.deb \
	libssl1.0.0_1.0.1t-1+deb8u6_armhf.deb

ln -sf /usr/lib/arm-linux-gnueabihf/qt4/bin/lrelease /usr/bin/lrelease

cd ..
rm -rf setup-tmp
