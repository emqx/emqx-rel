#! /bin/bash

cp ~/.ssh/id_rsa ./files
cp ~/.ssh/id_rsa.pub ./files

mkdir -p /home/ubuntu/package

#oslist=(debian7 debian8)
oslist=(debian7 debian8 centos6.8 centos7 ubuntu12.04 ubuntu14.04 ubuntu16.04)
#oslist=(debian7)
for var in ${oslist[@]};do
    #sudo docker build -t ci-${var} -f ${var}/Dockerfile .
    sudo docker rm -f emq-${var}
    sudo docker run -itd --net='host' --name emq-${var} -e "ostype=${var}" -e "host=13.112.29.140" ci-${var}
done
