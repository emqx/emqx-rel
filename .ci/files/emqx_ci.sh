#!/bin/bash
set -e

chmod 600 /root/.ssh/config

if [[ ! -z $(echo $version | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?") ]]
then
  export EMQX_DEPS_DEFAULT_VSN=$version # git tag for ALL emqx components
  export PKG_VSN=$version   # version number for package
  export REL_TAG=$version #  git tag to clone emqx-rel
fi

mkdir -p ${buildlocation}
rm -rf /tmp/emqx
rm -rf /emqx_temp && mkdir /emqx_temp
cp -rf /emqx_code/* /emqx_temp/

cd /emqx_temp/emqx-rel
pkg=emqx-${ostype}-${version}.zip
echo "building $pkg..."
make && cd _rel && zip -rq $pkg emqx 
mv $pkg ${buildlocation}

cd /emqx_temp/emqx-packages
make
mv package/* ${buildlocation}

/emqx_install_test.sh
ssh -o StrictHostKeyChecking=no ${host} "mkdir -p ${buildlocation}"
scp -o StrictHostKeyChecking=no ${buildlocation}/* ${host}:${buildlocation}