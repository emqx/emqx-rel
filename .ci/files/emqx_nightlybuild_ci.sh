#!/bin/bash

chmod 600 /root/.ssh/config

today=$(date +%Y%m%d)

rm -rf /emqx_temp && mkdir /emqx_temp
cp -rf /emqx_code/* /emqx_temp/
cd /emqx_temp
pkg=emqx-${ostype}-${versionid}-${type}-${today}.zip
echo "building $pkg..."
cd emqx-rel && make && cd _rel && zip -rq $pkg emqx \
    && scp -o StrictHostKeyChecking=no $pkg ${host}:${buildlocation} \
    && cd /emqx_temp

cd emqx-packages
sed -i "/EMQ_VERSION/c\EMQ_VERSION=${versionid}" ./Makefile
sed -i "/Version: /c\Version: ${versionid}" ./rpm/emqx.spec
sed -i "1c\emqx (${versionid}) unstable; urgency=medium" ./deb/debian/changelog
make
name=`basename package/*`
name2=${name/emqx-${versionid}/emqx-${ostype}-${versionid}-${type}-${today}}
name3=${name2/emqx_${versionid}/emqx-${ostype}-${versionid}-${type}-${today}}
mv package/${name} package/${name3}
scp -o StrictHostKeyChecking=no package/* ${host}:${buildlocation}