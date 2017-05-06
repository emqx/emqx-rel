#!/bin/bash

# Usage:
#       ./docker_ci.sh {version}
# Example:
#       ./docker_ci.sh 2.2-beta.1

package=emqttd-docker-v$1

git clone https://github.com/emqtt/emq-docker

cd emq-docker

sudo docker build -t ${package} .

sudo  docker save ${package} > ${package}

zip -r ${package}.zip ${package}

scp ${package}.zip root@emqtt.io:/root/releases/$1
