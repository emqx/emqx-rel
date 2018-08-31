#!/bin/bash

chmod 600 /root/.ssh/config
rm -rf /emqx_temp && mkdir /emqx_temp && cd /emqx_temp
git clone -b emqx30_release https://github.com/emqx/emqx-rel
version=`cd emqx-rel && git describe --abbrev=0 --tags`
pkg=emqx-${ostype}-${version}.zip
echo "building $pkg..."
cd emqx-rel && make && cd _rel && zip -rq $pkg emqx && scp $pkg root@${host}:/root/releases/${versionid}-${type} && cd /emqx_temp

git clone -b emqx30 https://github.com/emqx/emqx-packages
cd emqx-packages
make
name=`basename package/*`
name2=${name/emqx-${versionid}/emqx-${ostype}-${version}}
name3=${name2/emqx_${versionid}/emqx-${ostype}-${version}}
mv package/${name} package/${name3}
scp package/* root@${host}:/root/releases/${versionid}-${type}
