#!/bin/bash

rm -rf /emq_temp && mkdir /emq_temp && cd /emq_temp
git clone https://github.com/emqtt/emq-relx.git
version=`cd emq-relx && git describe --abbrev=0 --tags`
pkg=emqttd-${ostype}-${version}.zip
echo "building $pkg..."
cd emq-relx && make && cd _rel && zip -rq $pkg emqttd && scp $pkg ubuntu@${host}:/home/ubuntu/package/ && cd /emq_temp

git clone https://github.com/emqtt/emq-package.git
cd emq-package
make
name=`basename package/*`
name2=${name/emqttd/emqttd-${ostype}}
mv package/${name} package/${name2}
scp package/* ubuntu@${host}:/home/ubuntu/package/
