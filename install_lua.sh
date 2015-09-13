#!/usr/bin/env bash

echo "moving config & lua files"
sudo cp ./example/cas.conf /opt/nginx/conf/nginx.conf
sudo cp ./src/*.lua /opt/nginx/
