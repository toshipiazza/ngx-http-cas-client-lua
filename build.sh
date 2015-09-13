#!/usr/bin/env bash

echo "making build dir"
mkdir -p /tmp/build-nginx && cd /tmp/build-nginx

echo "getting lua nginx module"
git clone -q https://github.com/openresty/lua-nginx-module
echo "getting ngx devel kit"
git clone -q https://github.com/simpl/ngx_devel_kit
echo "getting lua resty cookie"
git clone -q https://github.com/cloudflare/lua-resty-cookie
echo "getting nginx"
wget --quiet 'http://nginx.org/download/nginx-1.7.10.tar.gz'
tar -xzf nginx-1.7.10.tar.gz

DEVEL_MODULE=`pwd`/ngx_devel_kit
LUA_MODULE=`pwd`/lua-nginx-module
COOKIE_MODULE=`pwd`/lua-resty-cookie

echo "building nginx & dependencies"
cd nginx-1.7.10/
./configure --prefix=/opt/nginx \
	--add-module=${DEVEL_MODULE} \
	--add-module=${LUA_MODULE} > /dev/null
make -j > /dev/null
sudo make install > /dev/null

# resty is a lua-only library
cd /tmp/build-nginx
sudo mv ./lua-resty-cookie/lib/resty/cookie.lua /opt/nginx
