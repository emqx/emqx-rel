#!/bin/bash

# Usage:
#       ./docker_ci.sh {version}
# Example:
#       ./docker_ci.sh 2.2-beta.1

package=emqx-docker-v$1

git clone -b X https://github.com/emqtt/emq-docker emqx-docker

cd emqx-docker

sudo docker build -t ${package} .

sudo docker save ${package} > ${package}

zip -r ${package}.zip ${package}

scp ${package}.zip root@emqtt.io:/root/releases/$1
