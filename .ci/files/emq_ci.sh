#!/bin/bash

chmod 600 /root/.ssh/config
rm -rf /emq_temp && mkdir /emq_temp && cd /emq_temp
git clone -b ${tag} https://github.com/emqtt/emq-relx.git
version=`cd emq-relx && git describe --abbrev=0 --tags`
pkg=emqttd-${ostype}-${version}.zip
echo "building $pkg..."
cd emq-relx && make && cd _rel && zip -rq $pkg emqttd && scp $pkg root@${host}:/root/releases/${versionid}-${type} && cd /emq_temp

git clone https://github.com/emqtt/emq-package.git
cd emq-package
make
name=`basename package/*`
name2=${name/emqttd-${versionid}/emqttd-${ostype}-${version}}
name3=${name2/emqttd_${versionid}/emqttd-${ostype}-${version}}
mv package/${name} package/${name3}
scp package/* root@${host}:/root/releases/${versionid}-${type}
