#!/bin/bash

package=emqttd-docker-v$1

git clone https://github.com/emqtt/emq-docker

sudo docker build -t ${package} .

sudo  docker save ${package} > ${package}

zip -r ${package}.zip ${package}

scp  ${package}.zip emqtt.io:/root/releases/$1
