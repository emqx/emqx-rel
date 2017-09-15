#! /bin/bash

# Usage:
#       ./bulid.sh {versionid} {type}
# Example:
#       ./bulid.sh 2.2 beta.1

cp ~/.ssh/id_rsa ./files
cp ~/.ssh/id_rsa.pub ./files

mkdir -p /home/ubuntu/package

oslist=(debian7 debian8 debian9 centos6.8 centos7 ubuntu12.04 ubuntu14.04 ubuntu16.04)
for var in ${oslist[@]};do
    sudo docker build -t ci-${var} -f ${var}/Dockerfile .
    sudo docker rm -f emq-${var}
    sudo docker run -itd --net='host' --name emq-${var} -e "ostype=${var}" -e "host=emqtt.io" -e "tag=release" -e "versionid=$1" -e "type=$2" ci-${var}
done
