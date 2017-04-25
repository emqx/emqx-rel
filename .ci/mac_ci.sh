#!/bin/bash

git clone -b release https://github.com/emqtt/emq-relx.git
version=`cd emq-relx && git describe --abbrev=0 --tags`
pkg=emqttd-macosx-${version}.zip
echo "building $pkg..."
cd emq-relx && make && cd _rel && zip -rq $pkg emqttd
scp rel/emqttd.zip emqtt.io:/root/releases/$1
