#!/bin/bash

# Usage:
#       ./mac_ci.sh {version}
# Example:
#       ./mac_ci.sh 2.2-beta.1

git clone -b release https://github.com/emqtt/emq-relx.git
version=`cd emq-relx && git describe --abbrev=0 --tags`
pkg=emqttd-macosx-${version}.zip
echo "building $pkg..."
cd emq-relx && make && cd _rel && zip -rq $pkg emqttd
scp _rel/$pkg root@emqtt.io:/root/releases/$1
