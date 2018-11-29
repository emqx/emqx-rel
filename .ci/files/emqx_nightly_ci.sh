#!/bin/bash
set -e

chmod 600 /root/.ssh/config

today=$(date +%Y%m%d)
mkdir -p ${buildlocation}

rm -rf /emqx_temp && mkdir /emqx_temp
cp -rf /emqx_code/* /emqx_temp/

cd /emqx_temp/emqx-rel 
versionid=${version##*v}
export versionid=${versionid%-*}
export type=${version#*-}

pkg=emqx-${ostype}-${version}-${today}.zip
echo "building $pkg..."
make && cd _rel && zip -rq $pkg emqx 
mv $pkg ${buildlocation}

cd /emqx_temp/emqx-packages
#sed -i "/REL_TAG/c\REL_TAG=emqx30" ./Makefile
sed -i "/EMQ_VERSION/c\EMQ_VERSION=${versionid}" ./Makefile
sed -i "/Version: /c\Version: ${versionid}" ./rpm/emqx.spec
sed -i "1c\emqx (${versionid}) unstable; urgency=medium" ./deb/debian/changelog
make
name=`basename package/*`
name2=${name/emqx-${versionid}/emqx-${ostype}-${version}-${today}}
name3=${name2/emqx_${versionid}/emqx-${ostype}-${version}-${today}}
mv package/${name} ${buildlocation}/${name3}

./emqx_install_test.sh
ssh -o StrictHostKeyChecking=no ${host} "mkdir -p ${buildlocation}"
scp -o StrictHostKeyChecking=no ${buildlocation}/* ${host}:${buildlocation}