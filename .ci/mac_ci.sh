#!/bin/bash

# Usage:
#       ./mac_ci.sh {version}
# Example:
#       ./mac_ci.sh 2.2-beta.1

git clone -b release https://github.com/emqtt/emq-relx.git emqx-rel
version=`cd emqx-rel && git describe --abbrev=0 --tags`
pkg=emqx-macosx-${version}.zip
echo "building $pkg..."
cd emqx-rel && make && cd _rel && zip -rq $pkg emqx
scp _rel/$pkg root@emqtt.io:/root/releases/$1
