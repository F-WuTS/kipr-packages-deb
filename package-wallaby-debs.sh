#!/bin/bash

set -e

export CC=arm-linux-gnueabihf-gcc
export CXX=arm-linux-gnueabihf-g++
export CFLAGS="-I/usr/include -I/usr/local/include -march=armv7"
export CXXFLAGS="$CFLAGS"
export OpenCV_DIR="`pwd`/wallaby-build/opencv-2.4.12.3/build"

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

	echo "$name for Wallaby" > description-pak
	sudo checkinstall \
	        --default \
	        --arch=armhf \
	        --pkgname=$name \
	        --maintainer="me@christoph-heiss.me" \
	        --pkggroup=wallaby \
		--requires=$3 \
		--backup=no

	cp "${name}_`date +%Y%m%d`-1_armhf.deb" ../../debs/
	cd ../..
}

function build_opencv {
	wget "https://github.com/opencv/opencv/archive/2.4.12.3.tar.gz"
	tar -xf "2.4.12.3.tar.gz"

	cd opencv-2.4.12.3
	mkdir build
	cd build

	cmake \
		-DBUILD_DOCS=OFF -DBUILD_PACKAGE=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_TESTS=OFF \
		-DBUILD_opencv_apps=OFF -DBUILD_opencv_calib3d=OFF -DBUILD_opencv_gpu=OFF \
		-DBUILD_opencv_flann=OFF -DBUILD_opencv_legacy=OFF -DBUILD_opencv_ml=OFF \
		-DBUILD_opencv_nonfree=OFF -DBUILD_opencv_ocl=OFF -DBUILD_opencv_superres=OFF \
		-DBUILD_opencv_video=OFF -DBUILD_opencv_videostab=OFF ..
	make -j`nproc`

	cd ../..
}


sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


rm -rf wallaby-build
mkdir -p wallaby-build/debs

cd wallaby-build

build_opencv

build_package kipr/bsonbind master
build_package kipr/libkar use_Qt4 "libqt4-dev"
build_package kipr/pcompiler use_Qt4 "libqt4-dev,libkar"
build_package kipr/daylite master "libbson-dev,libboost-dev,bsonbind"
build_package kipr/libaurora master "libpng-dev,zlib1g-dev"
build_package kipr/libwallaby master "libzbar-dev,libopencv-dev,libjpeg-dev,python-dev" "-DBUILD_DOCUMENTATION=OFF -Dbuild_python=OFF"
build_package kipr/libbotball master "libaurora,libwallaby"
build_package robot0nfire/botui master "libqt4-dev,pcompiler,libssl-dev"

cd debs/
wget "http://ftp.debian.org/debian/pool/main/libb/libbson/libbson-1.0-0_1.6.3-1_armhf.deb"

sudo dpkg -r botui libbotball libwallaby libaurora daylite pcompiler libkar bsonbind
