#!/bin/bash
set -e

chmod 600 /root/.ssh/config

versionid=$(echo $version | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?")
if [[ -z $versionid ]]
then
  versionid=3.0
  today=$(date +%Y%m%d)
  packagename=emqx-${ostype}-${today} 
else
  export EMQX_DEPS_DEFAULT_VSN=$version # git tag for ALL emqx components
  export PKG_VSN=$version   # version number for package
  export REL_TAG=$version #  git tag to clone emqx-rel
  packagename=emqx-$ostype-$version
fi

releaseid=$(echo $version | grep -oE "(alpha|beta|rc)\.[0-9]")
if [[ -z $releaseid ]]
then
  releaseid=1
fi


mkdir -p ${buildlocation}
rm -rf /tmp/emqx
rm -rf /emqx_temp && mkdir /emqx_temp
cp -rf /emqx_code/* /emqx_temp/

cd /emqx_temp/emqx-rel
pkg=${packagename}.zip
echo "building $pkg..."
make && cd _rel && zip -rq $pkg emqx 
mv $pkg ${buildlocation}

cd /emqx_temp/emqx-packages
make
name=`basename package/*`
name2=${name/emqx-${versionid}-${releaseid}/${packagename}}
name3=${name2/emqx_${versionid}_/${packagename}-}
mv package/${name} ${buildlocation}/${name3}

/emqx_install_test.sh
ssh -o StrictHostKeyChecking=no ${host} "mkdir -p ${buildlocation}"
scp -o StrictHostKeyChecking=no ${buildlocation}/* ${host}:${buildlocation}