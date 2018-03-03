#!/bin/bash

set -e

export CC=arm-linux-gnueabihf-gcc
export CXX=arm-linux-gnueabihf-g++
export CFLAGS="-I/usr/include -I/usr/local/include -march=armv7"
export CXXFLAGS="$CFLAGS"
export OpenCV_DIR="/usr/include/opencv2/"

function build_package {
	local name=(${1//// })
	name=${name[1]}

	git clone https://github.com/$1.git
	cd $name

	git checkout $2
	mkdir build
	cd build

	cmake $4 ..
	make -j`nproc`

	# checkinstall sucks
	sudo make install

	echo "$name for Wallaby" > description-pak
	sudo checkinstall \
	        --default \
	        --arch=armhf \
	        --pkgname=$name \
	        --maintainer="me@christoph-heiss.me" \
	        --pkggroup=wallaby \
		--requires=$3 \
		--backup=no \
		--fstrans=yes

	cp "${name}_`date +%Y%m%d`-1_armhf.deb" ../../debs/
	cd ../..
}


sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

rm -rf wallaby-build
mkdir -p wallaby-build/debs

cd wallaby-build

build_package kipr/bsonbind master
build_package kipr/libkar use_Qt4 "libqt4-dev"
build_package kipr/pcompiler use_Qt4 "libqt4-dev,libkar"
build_package kipr/daylite master "libbson-dev,libboost-dev,bsonbind"
build_package kipr/libaurora master "libpng-dev,zlib1g-dev"
build_package F-WuTS/libwallaby master "libcv-dev,libjpeg-dev" "-DBUILD_DOCUMENTATION=OFF -Dbuild_python=OFF"
build_package kipr/libbotball master "libaurora,libwallaby"
build_package F-WuTS/botui master "libcv-dev,libqt4-dev,pcompiler"

sudo dpkg -r botui libbotball libwallaby libaurora daylite pcompiler libkar bsonbind
