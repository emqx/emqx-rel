#!/bin/bash

# Usage:
#       ./mac_ci.sh {version}
# Example:
#       ./mac_ci.sh v2.2-beta.1
version=$1
export EMQX_DEPS_DEFAULT_VSN=${version}

git clone -b ${version} https://github.com/emqx/emqx-rel
version=`cd emqx-rel && git describe --abbrev=0 --tags`
pkg=emqx-macosx-${version}.zip
echo "building $pkg..."
cd emqx-rel && make && cd _rel && zip -rq $pkg emqx
echo "building $pkg success" 
