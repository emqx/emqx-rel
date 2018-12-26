#!/bin/bash

set -o errexit

main() {
    chmod 600 /root/.ssh/config
    emqx_prepare
    emqx_build
    emqx_test
    emqx_scp
    echo "build success"
}

emqx_prepare(){
    if [ -z ${version} ];then
        export version=emqx30
    fi

    if [[ ! -z $(echo $version | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?") ]]
    then
        export EMQX_DEPS_DEFAULT_VSN=$version # git tag for ALL emqx components
        export PKG_VSN=$version   # version number for package
        export REL_TAG=$version #  git tag to clone emqx-rel
    fi

    if [ -z ${buildlocation} ];then
        export buildlocation=/opt/emq_packages/free
    fi

    if [ ! -d "/emqx_code/emqx-rel" ]; then
        git clone -b $version https://github.com/emqx/emqx-rel.git /emqx_code/emqx-rel
    fi
    if [ ! -d "/emqx_code/emqx-packages" ]; then
        git clone -b $version https://github.com/emqx/emqx-packages.git /emqx_code/emqx-packages
    fi
    if [ ! -d "/emqx_code/paho-mqtt-testing" ]; then
        git clone -b master https://github.com/emqx/paho.mqtt.testing.git /emqx_code/paho-mqtt-testing
    fi

    rm -rf /tmp/emqx
    rm -rf /emqx_temp
    mkdir -p ${buildlocation}
    mkdir /emqx_temp
    cp -rf /emqx_code/* /emqx_temp/
}

emqx_build() {
    cd /emqx_temp/emqx-rel
    pkg=emqx-${ostype}-${version}.zip
    echo "building $pkg..."
    make && cd _rel && zip -rq $pkg emqx 
    mv $pkg ${buildlocation}

    cd /emqx_temp/emqx-packages
    make
    mv package/* ${buildlocation}
}

emqx_test(){
    packagespath=${buildlocation}
    cd $packagespath
    packages=$(ls $buildlocation/emqx-*)

    for var in ${packages[@]};do
        case ${var##*.} in
            "zip")
                zipname=`basename $packagespath/emqx-*.zip`
                unzip $packagespath/$zipname -d $packagespath
                cd $packagespath/emqx
                sed -i "/zone.external.server_keepalive/c zone.external.server_keepalive = 60" $packagespath/emqx/etc/emqx.conf 
                sed -i "/mqtt.max_topic_alias/c mqtt.max_topic_alias = 10" $packagespath/emqx/etc/emqx.conf
                $packagespath/emqx/bin/emqx start
                if [[ -z "$($packagespath/emqx/bin/emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
                then
                    echo "emqx running error"
                    exit 1
                fi
                echo "running ${packagename} start"
                python3 /emqx_temp/paho-mqtt-testing/interoperability/client_test5.py || { echo "Paho test error."; exit 1; } 
                $packagespath/emqx/bin/emqx stop
                echo "running ${packagename} start"
                rm -rf $packagespath/emqx
            ;;
            "deb")
                packagename=`basename $packagespath/emqx-*.deb`
                dpkg -i $packagespath/$packagename
                if [ $(dpkg -l |grep emqx |awk '{print $1}') != "ii" ]
                then
                    echo "package install error"
                    exit 1
                fi
                
                echo "running ${packagename} start"
                running_test 
                echo "running ${packagename} stop"

                dpkg -r emqx
                if [ $(dpkg -l |grep emqx |awk '{print $1}') != "rc" ]
                then
                    echo "package remove error"
                    exit 1
                fi

                dpkg -P emqx
                if [[ ! -z "$(dpkg -l |grep emqx)" ]]
                then
                    echo "package uninstall error"
                    exit 1
                fi
            ;;
            "rpm")
                packagename=`basename $packagespath/emqx-*.rpm`
                rpm -ivh $packagespath/$packagename
                if [[ $(rpm -q emqx) != emqx* ]];then
                    echo "package install error"
                    exit 1
                fi
                
                echo "running ${packagename} start"
                running_test 
                echo "running ${packagename} stop"
                
                rpm -e emqx
                if [[ $(rpm -q emqx) == emqx* ]];then
                    echo "package uninstall error"
                    exit 1
                fi  
            ;;

        esac
    done
}

emqx_scp(){
    ssh -o StrictHostKeyChecking=no ${host} "mkdir -p ${buildlocation}"
    scp -o StrictHostKeyChecking=no ${buildlocation}/* ${host}:${buildlocation}
}

running_test(){
    if [[ ! -z $(echo $EMQX_DEPS_DEFAULT_VSN | grep -oE "v[0-9]+\.[0-9]+(\.[0-9]+)?-(alpha|beta|rc)\.[0-9]") ]];then
        if [[ -z $(ls /usr/lib/emqx/lib| grep emqx-$EMQX_DEPS_DEFAULT_VSN) ]]
        then
            echo "emqx package version error"
            exit 1
        fi
    fi

    sed -i "/zone.external.server_keepalive/c zone.external.server_keepalive = 60" /etc/emqx/emqx.conf
    sed -i "/mqtt.max_topic_alias/c mqtt.max_topic_alias = 10" /etc/emqx/emqx.conf

    emqx start
    if [[ -z "$(emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
    then
        echo "emqx running error"
        exit 1
    fi
    python3 /emqx_temp/paho-mqtt-testing/interoperability/client_test5.py || { echo "Paho test error."; exit 1; }
    emqx stop

    if [ $ostype != centos7 ]
    then
        service emqx start
        if [[ -z "$(emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
        then
            echo "emqx service error"
            exit 1
        fi
        service emqx stop
    fi
}

main