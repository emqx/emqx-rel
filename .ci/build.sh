#!/bin/bash
#buildserver=ubuntu@172.31.10.24
#buildbase=/opt/emq_packages/free
#version=emqx30

set -o errexit

sudo docker run --rm --privileged multiarch/qemu-user-static:register --reset

if [[ ! -z $(echo $version | grep -oE "v[0-9]+\.[0-9]+(\.[0-9]+)?") ]]
then
	buildname=rel
    buildlocation=${buildbase}/${version}/
else
	buildname=nb
	today=$(date +%Y-%m-%d)
	buildlocation=${buildbase}/nightly-build/${today}
fi

ssh -o StrictHostKeyChecking=no ${buildserver} "mkdir -p ${buildlocation}"


cd "${WORKSPACE}/emqx-rel/.ci"
commitid=$(git rev-parse HEAD)
if [[ ! -z $(git show ${commitid} .ci/) ]]
then
	sudo ./docker-image-build.sh ${dockeruser} ${dockerpasswd}
fi

# build zip/packages 
key=$RANDOM
oslist=$(ls -l |grep -v 'files' |awk '/^d/ {print $NF}')
#oslist=(centos7 ubuntu18.04)
for var in ${oslist[@]};do
    sudo docker run -d \
        --name emqx-${key}-${buildname}-${var} \
        -v "${WORKSPACE}":/emqx_code \
        -e "ostype=${var}" \
        -e "host=${buildserver}" \
        -e "version=${version}" \
        -e "buildlocation=${buildlocation}" \
        emqx/build-env:${var} 
done

sudo docker ps -f name=emqx-${key}-${buildname}-*  -f status=running --format "{{.Names}}: {{.Status}}"

# check docker containers status
while [ $(sudo docker ps -f name=emqx-${key}-${buildname}-*  -f status=running --format "{{.Names}}" |wc -l) -ne 0 ]; do
	sleep 30;
done

failed=0
list=$(sudo docker ps -f name=emqx-${key}-${buildname}-* --format "{{.Names}}: {{.Status}}" -a)
for(( i=0; i<${#list[@]}; i++ )) ; do
	echo "${list[$i]}"
    if [[ ! ${list[$i]} =~ "Exited (0)" ]]; then
       let failed++ 
    fi  
done

if [[ ${failed} -ne 0 ]]; then
    exit 1
else
	sudo docker rm $(sudo docker ps -a |grep emqx-${key}-${buildname} | awk '{print $1}')
	sudo docker rmi $(sudo docker images -f "dangling=true" -q)
	sudo docker volume rm $(sudo docker volume ls -qf dangling=true)
    exit 0
fi