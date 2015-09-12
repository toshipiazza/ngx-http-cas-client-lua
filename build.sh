#!/usr/bin/env bash

REPO_DIR=`pwd`

echo "making build dir"
mkdir -p /tmp/build-nginx && cd /tmp/build-nginx

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
	--add-module=${LUA_MODULE} > /dev/null

make -j > /dev/null
sudo make install > /dev/null

cd $REPO_DIR

echo "moving config files"
sudo cp ./example/cas.conf /opt/nginx/conf/nginx.conf
sudo cp ./src/cas*.lua /opt/nginx/

