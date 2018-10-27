#!/bin/bash

chmod 600 /root/.ssh/config

if [[ ${tag} == "nightlybuild-ci" ]]
then
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

elif [[ ${tag} == "releasebuild-ci" ]] 
then

  rm -rf /emqx_temp && mkdir /emqx_temp
  cp -rf /emqx_code/* /emqx_temp/

  cd /emqx_temp/emqx-rel
  version=`git describe --abbrev=0 --tags`
  versionid=${version##*v}
  export versionid=${versionid%-*}
  export type=${version#*-}

  pkg=emqx-${ostype}-${version}.zip
  echo "building $pkg..."
  make && cd _rel && zip -rq $pkg emqx 
  ssh -o StrictHostKeyChecking=no ${host} "mkdir -p ${buildlocation}"
  scp -o StrictHostKeyChecking=no $pkg ${host}:${buildlocation}/. 

  cd /emqx_temp/emqx-packages
  sed -i "/EMQ_VERSION/c\EMQ_VERSION=${versionid}" ./Makefile
  sed -i "/Version: /c\Version: ${versionid}" ./rpm/emqx.spec
  sed -i "1c\emqx (${versionid}) unstable; urgency=medium" ./deb/debian/changelog
  make
  name=`basename package/*`
  name2=${name/emqx-${versionid}/emqx-${ostype}-${version}}
  name3=${name2/emqx_${versionid}/emqx-${ostype}-${version}}
  mv package/${name} package/${name3}  
  scp -o StrictHostKeyChecking=no package/* ${host}:${buildlocation}/.

else
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
fi
