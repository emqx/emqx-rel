#!/bin/bash
set -e

chmod 600 /root/.ssh/config
export EMQX_DEPS_DEFAULT_VSN=${version} # git tag for ALL emqx components
export PKG_VSN=${version}   # version number for packages
export REL_TAG=${version} #  git tag to clone emqx-rel

mkdir -p ${buildlocation}
rm -rf /emqx_temp && mkdir /emqx_temp
cp -rf /emqx_code/* /emqx_temp/

cd /emqx_temp/emqx-rel
pkg=emqx-${ostype}-${version}.zip
echo "building $pkg..."
make && cd _rel && zip -rq $pkg emqx 
mv $pkg ${buildlocation}

cd /emqx_temp/emqx-packages
make
versionid=${version##*v}
versionid=${versionid%-*}
name=`basename package/*`
name2=${name/emqx-${versionid}/emqx-${ostype}-${version}}
name3=${name2/emqx_${versionid}/emqx-${ostype}-${version}}
mv package/${name} ${buildlocation}/${name3}

/emqx_install_test.sh
ssh -o StrictHostKeyChecking=no ${host} "mkdir -p ${buildlocation}"
scp -o StrictHostKeyChecking=no ${buildlocation}/* ${host}:${buildlocation}
