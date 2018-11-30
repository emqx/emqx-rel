#!/bin/bash
set -e

chmod 600 /root/.ssh/config
today=$(date +%Y%m%d)

mkdir -p ${buildlocation}
rm -rf /emqx_temp && mkdir /emqx_temp
cp -rf /emqx_code/* /emqx_temp/

cd /emqx_temp/emqx-rel 
pkg=emqx-${ostype}-${version}-${today}.zip
echo "building $pkg..."
make && cd _rel && zip -rq $pkg emqx 
mv $pkg ${buildlocation}

cd /emqx_temp/emqx-packages
make
versionid=${version##*v}
versionid=${versionid%-*}
name=`basename package/*`
name2=${name/emqx-${version}/emqx-${ostype}-${version}-${today}}
name3=${name2/emqx_${version}/emqx-${ostype}-${version}-${today}}
mv package/${name} ${buildlocation}/${name3}

/emqx_install_test.sh
ssh -o StrictHostKeyChecking=no ${host} "mkdir -p ${buildlocation}"
scp -o StrictHostKeyChecking=no ${buildlocation}/* ${host}:${buildlocation}
