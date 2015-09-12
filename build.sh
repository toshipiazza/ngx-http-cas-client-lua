#!/usr/bin/env bash

mkdir -p build && cd build

# dependencies
git clone https://github.com/openresty/lua-nginx-module
git clone https://github.com/simpl/ngx_devel_kit
wget 'http://nginx.org/download/nginx-1.7.10.tar.gz'
tar -xzvf nginx-1.7.10.tar.gz

DEVEL_MODULE=`pwd`/ngx_devel_kit
LUA_MODULE=`pwd`/lua-nginx-module

echo "DEBUG: DEVEL_MODULE=${DEVEL_MODULE}"
echo "DEBUG: LUA_MODULE=${LUA_MODULE}"

