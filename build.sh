#!/usr/bin/env bash

echo "making build dir"
mkdir -p build && cd build

# dependencies
echo "getting lua nginx module"
git clone -q https://github.com/openresty/lua-nginx-module
echo "getting ngx devel kit"
git clone -q https://github.com/simpl/ngx_devel_kit
echo "getting nginx"
wget --quiet 'http://nginx.org/download/nginx-1.7.10.tar.gz'
tar -xzf nginx-1.7.10.tar.gz

DEVEL_MODULE=`pwd`/ngx_devel_kit
LUA_MODULE=`pwd`/lua-nginx-module

cd nginx-1.7.10/
./configure --prefix=/opt/nginx \
	--add-module=${DEVEL_MODULE} \
	--add-module=${LUA_MODULE}

make -j
