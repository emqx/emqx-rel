#!/bin/bash

buildname=nb
#versionid=3.0
#type=beta.1
#buildserver=52.79.226.125
#buildbase=/home/ubuntu/builds
#tag=nightlybuild-ci
#timeout=50


cp ~/.ssh/id_rsa "${WORKSPACE}/emqx-rel/.ci/files"
cp ~/.ssh/id_rsa.pub "${WORKSPACE}/emqx-rel/.ci/files"

mkdir -p /home/ubuntu/package

# build docker image
today=$(date +%Y%m%d)
ssh ubuntu@${buildserver} "mkdir ${buildbase}/${versionid}-${type}"
ssh ubuntu@${buildserver} "mkdir ${buildbase}/${versionid}-${type}/${today}"
buildlocation=${buildbase}/${versionid}-${type}/${today}
  
cd "${WORKSPACE}/emqx-docker"
sed -i "/ENV EMQX_VERSION/c\ENV EMQX_VERSION=${versionid}-${type}" ./Dockerfile
sudo docker build -t emqx-docker-${versionid}-${type}-${today}:latest .
sudo docker save -o emqx-docker-${versionid}-${type}-${today}.zip emqx-docker-${versionid}-${type}-${today}:latest
sudo chmod -R 444 emqx-docker-${versionid}-${type}-${today}.zip
scp emqx-docker-${versionid}-${type}-${today}.zip ubuntu@${buildserver}:${buildlocation}
sudo rm emqx-docker-${versionid}-${type}-${today}.zip

# build zip/packages 
cd "${WORKSPACE}/emqx-rel/.ci"

oslist=(debian7 debian8 debian9 centos6.8 centos7 ubuntu12.04 ubuntu14.04 ubuntu16.04 ubuntu18.04)
#oslist=(centos7)
for var in ${oslist[@]};do
    sudo docker build -t emq_ci-${buildname}-${var} -f ${var}/Dockerfile .
    sudo docker rm -f emq-${buildname}-${var}
    sudo docker run -itd --net='host' --name emq-${buildname}-${var} -v "${WORKSPACE}":/emqx_code -e "ostype=${var}" -e "host=${buildserver}" -e "tag=${tag}" -e "versionid=${versionid}" -e "type=${type}" -e "buildlocation=${buildlocation}" emq_ci-${buildname}-${var}
done

# check docker containers status
try=0
failure=""
suc=""
finished=0

while [ ${finished} -ne ${#oslist[@]} ] && [ ${try} -lt $[${timeout}*2] ]; do
    sleep 30
    building=""
    finished=0
    let try++
    for(( i=0; i<${#oslist[@]}; i++ )) ; do
        os=${oslist[i]}
        status=`sudo docker ps -f name=emq-${buildname}-${os} -f status=exited --format "{{.Status}}"`
        if [[ ${status} != "" ]]
        then
            let finished++
            if [[ ${status} =~ "Exited (0)" ]]
            then
            	if [[ !(${suc} =~ ${os}) ]]
                then
                	echo -e "${os} successfully built."
                    suc=${suc}${os}" "
                fi
            else
            	if [[ !(${failure} =~ ${os}) ]]
                then
                	echo -e "${os} failed to build."
                	failure=${failure}${os}" "
                fi
            fi
        else
            building=${building}${os}" "                   
        fi
    done
done

#echo -e "try: ${try}"
if [[ ${finished} -ne ${#oslist[@]} ]]
then
    echo -e "${building} cannot be built within timeout."
    if [[ ${failure} != "" ]]
    then
        echo -e "${failure} failed to build."
    fi
    exit 1
fi

if [[ ${failure} != "" ]]
then
    echo -e "${failure} failed to build."
    exit 1
else
    exit 0
fi
