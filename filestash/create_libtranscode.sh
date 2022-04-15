#!/bin/sh
# # This script handle the creation of the static library used by the plugin to
# # perform transcoding jobs. You can run it like this:
# docker run -ti --name debian_build_dep -v /home/:/home/ debian:9 bash
# apt-get -y update && apt-get -y install git
# git clone https://github.com/mickael-kerjean/filestash
# cd filestash/server/plugin/plg_image_light/deps/
# ./create_libtranscode.sh
set -e
arch=$(dpkg --print-architecture)


################################################
# Tooling
apt install -y --allow-unauthenticated curl make gcc g++ xz-utils pkg-config python3-pip autoconf libtool unzip python-setuptools cmake git
export PATH=~/.local/bin:$PATH

################################################
# Stage 1: Get libraw and its dependencies
INITIAL_PATH=`pwd`
apt install -y --allow-unauthenticated libraw-dev
cd /tmp/
# libgomp and libstdc++
apt-get install --allow-unauthenticated -y libgcc-6-dev
# libjpeg
apt-get install --allow-unauthenticated -y  libjpeg-dev
# liblcms2
curl -L -O -k https://downloads.sourceforge.net/project/lcms/lcms/2.9/lcms2-2.9.tar.gz
tar zxf lcms2-2.9.tar.gz
cd lcms2-2.9
./configure --enable-static --without-zlib --without-threads
make -j 8
make install

cd $INITIAL_PATH
################################################
# Stage 2: Create our own library as a static build
gcc -Wall -c src/libtranscode.c

################################################
# Stage 3: Gather and assemble all the bits and pieces together
libpath='aarch64-linux-gnu'
ar x /usr/lib/$libpath/libraw.a
ar x /usr/lib/$libpath/libjpeg.a
ar x /usr/local/lib/liblcms2.a
ar x /usr/lib/gcc/$libpath/6/libstdc++.a
ar x /usr/lib/gcc/$libpath/6/libgomp.a
ar x /usr/lib/$libpath/libpthread.a

ar rcs libtranscode.a *.o
rm *.o

#scp libtranscode.a mickael@hal.kerjean.me:/home/app/pages/data/projects/filestash/downloads/upload/libtranscode_`uname -s`-`uname -m`.a

################################################
# Stage 4: Gather all the related headers
#cd /usr/include/
#tar zcf /tmp/libtranscode-headers.tar.gz .
#scp /tmp/libtranscode-headers.tar.gz mickael@hal.kerjean.me:/home/app/pages/data/projects/filestash/downloads/upload/libtranscode_`uname -s`-`uname -m`_headers.tar.gz
