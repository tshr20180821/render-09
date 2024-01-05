#!/bin/bash

set -e

pushd /tmp

curl -O https://memcached.org/files/memcached-1.6.22.tar.gz

tar xf memcached-1.6.22.tar.gz

pushd memcached-1.6.22

./configure --help

# ./configure --enable-sasl --enable-sasl-pwdb --enable-static --enable-64bit --disable-docs
./configure --enable-sasl --enable-sasl-pwdb --enable-64bit --disable-docs

time make

make install

popd

ldd /usr/local/bin/memcached
cp /usr/local/bin/memcached /var/www/html/

popd
