#!/bin/bash
set -e

mkdir -p $HOME/.docker

# enable experimental to use docker manifest command
echo '{
  "experimental": "enabled"
}' | tee $HOME/.docker/config.json

# enable experimental
echo '{
  "experimental": true,
  "storage-driver": "overlay2",
  "max-concurrent-downloads": 50,
  "max-concurrent-uploads": 50
}' | sudo tee /etc/docker/daemon.json

sudo service docker restart

sudo docker run --rm --privileged multiarch/qemu-user-static:register --reset

cp ~/.ssh/id_rsa files/
cp ~/.ssh/id_rsa.pub files/
curl -L -o files/qemu-arm-static.tar.gz https://github.com/multiarch/qemu-user-static/releases/download/v3.0.0/qemu-arm-static.tar.gz
tar xzf files/qemu-arm-static.tar.gz -C files/

docker login -u $1 -p $2
oslist=$(ls -l |grep -v 'files' |awk '/^d/ {print $NF}')
for var in ${oslist[@]};do
    echo "build ${var} start"
    docker build --no-cache -t emqx/build-env:${var} -f ${var}/Dockerfile .
    docker push emqx/build-env:${var}
    echo "push ${var} success"
done
docker logout