#!/bin/bash
set -ex

REPOPATH=/repos
PKGPATH=/packages

version=$1
if [ -z "$(echo $version | grep -oE '(alpha|beta|rc)\.[0-9]')" ]; then 
    stable=stable 
else
    stable=unstable
fi

rm -rf ${PKGPATH}
for emqx in emqx-ce emqx-edge emqx-ee;do
    case ${emqx} in
    emqx-ce)
        broker="broker"
        ;;
    emqx-edge)
        broker="edge"
        ;;
    emqx-ee)
        broker="enterprise"
        ;;
    esac

    mkdir -p ${PKGPATH}
    cd ${PKGPATH} && wget -r -np -nH -R index.html https://www.emqx.io/downloads/${broker}/${version}
    if [ ! -d ${PKGPATH}/downloads/${broker}/${version} ]; then continue; fi
    cd ${PKGPATH}/downloads/${broker}/${version}
    for var in $(ls emqx-* |grep -v sha256); do 
        sha256sum -c <(grep $var $var.sha256)
    done
    for var in $(ls emqx-* |grep -vE "sha256|zip"); do
        system=$(echo $var | sed -r "s ${emqx}-(.*)-v.* \1 g" )
        case $system in
        "centos6")
            mkdir -p ${REPOPATH}/${emqx}/redhat/centos/6/${stable}
            mv $var ${REPOPATH}/${emqx}/redhat/centos/6/${stable}/${var}
            ;;
        "centos7")
            mkdir -p ${REPOPATH}/${emqx}/redhat/centos/7/${stable}
            mv $var ${REPOPATH}/${emqx}/redhat/centos/7/${stable}/${var}
            ;;
        "opensuse")
            mkdir -p ${REPOPATH}/${emqx}/redhat/opensuse/tumbleweed/${stable}
            mv $var ${REPOPATH}/${emqx}/redhat/opensuse/tumbleweed/${stable}/${var}
            ;;
        "debian10")
            mkdir -p ${REPOPATH}/${emqx}/deb/debian/dists/buster/pool/${stable}/amd64
            mv $var ${REPOPATH}/${emqx}/deb/debian/dists/buster/pool/${stable}/amd64/${var}
            ;;
        "debian8")
            mkdir -p ${REPOPATH}/${emqx}/deb/debian/dists/jessie/pool/${stable}/amd64
            mv $var ${REPOPATH}/${emqx}/deb/debian/dists/jessie/pool/${stable}/amd64/${var}
            ;;
        "debian9")
            mkdir -p ${REPOPATH}/${emqx}/deb/debian/dists/stretch/pool/${stable}/amd64
            mv $var ${REPOPATH}/${emqx}/deb/debian/dists/stretch/pool/${stable}/amd64/${var}
            ;;
        "raspbian10")
            mkdir -p ${REPOPATH}/${emqx}/deb/raspbian/dists/buster/pool/stable/armhf
            mv $var ${REPOPATH}/${emqx}/deb/raspbian/dists/buster/pool/stable/armhf/${var}
            ;;
        "raspbian8")
            mkdir -p ${REPOPATH}/${emqx}/deb/raspbian/dists/jessie/pool/stable/armhf
            mv $var ${REPOPATH}/${emqx}/deb/raspbian/dists/jessie/pool/stable/armhf/${var}
            ;;
        "raspbian9")
            mkdir -p ${REPOPATH}/${emqx}/deb/raspbian/dists/stretch/pool/stable/armhf
            mv $var ${REPOPATH}/${emqx}/deb/raspbian/dists/stretch/pool/stable/armhf/${var}
            ;;
        "ubuntu14.04")
            mkdir -p ${REPOPATH}/${emqx}/deb/ubuntu/dists/xenial/pool/${stable}/amd64
            mv $var ${REPOPATH}/${emqx}/deb/ubuntu/dists/xenial/pool/${stable}/amd64/${var}
            ;;
        "ubuntu16.04")
            mkdir -p ${REPOPATH}/${emqx}/deb/ubuntu/dists/trusty/pool/${stable}/amd64
            mv $var ${REPOPATH}/${emqx}/deb/ubuntu/dists/trusty/pool/${stable}/amd64/${var} 
            ;;
        "ubuntu18.04")
            mkdir -p ${REPOPATH}/${emqx}/deb/ubuntu/dists/bionic/pool/${stable}/amd64
            mv $var ${REPOPATH}/${emqx}/deb/ubuntu/dists/bionic/pool/${stable}/amd64/${var}  
            ;;
        esac
    done
done
