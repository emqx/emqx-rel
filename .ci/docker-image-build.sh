#!/bin/bash
set -e

docker login -u $1 -p $2
oslist = $(ls -l |grep -v 'files' |awk '/^d/ {print $NF}')
for var in ${oslist[@]};do
    echo "build ${var} start"
    docker build --no-cache -t emqx/build-env:${var} -f ${var}/Dockerfile .
    docker push emqx/build-env:${var}
    echo "push ${var} success"
done
docker logout