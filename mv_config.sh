#!/usr/bin/env bash

echo "moving config files"
sudo cp ./example/cas.conf /opt/nginx/conf/nginx.conf
sudo cp ./src/*.lua /opt/nginx/
