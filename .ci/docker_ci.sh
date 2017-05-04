#!/bin/bash

package=emqttd-docker-v2.1.0

git clone https://github.com/emqtt/emq-docker

sudo docker build -t ${package} .

sudo  docker save ${package} > ${package}

zip -r ${package}.zip ${package}

