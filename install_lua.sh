#!/usr/bin/env bash

echo "moving config & lua files"
sudo cp ./example/*.conf /opt/nginx/conf/
sudo cp ./src/*.lua /opt/nginx/
