#!/bin/bash

set -e

export DISTCC_HOSTS="127.0.0.1"

pushd /tmp

curl -O https://memcached.org/files/memcached-1.6.22.tar.gz

tar xf memcached-1.6.22.tar.gz

pushd memcached-1.6.22

./configure --help

# ./configure --enable-sasl --enable-sasl-pwdb --enable-static --enable-64bit --disable-docs
./configure --enable-sasl --enable-sasl-pwdb --enable-64bit --disable-docs

# time make
time MAKEFLAGS="CC=distcc\ gcc" make -j2

make install

popd

ldd /usr/local/bin/memcached
cp /usr/local/bin/memcached /var/www/html/

popd
