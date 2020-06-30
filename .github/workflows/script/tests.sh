#!/bin/sh
set -x -e -u
export EMQX_NAME=${EMQX_NAME:-"emqx"}
export PACKAGE_PATH="/emqx-rel/_packages/${EMQX_NAME}"
# export EMQX_NODE_NAME="emqx-on-$(uname -m)@127.0.0.1"
# export EMQX_NODE_COOKIE=$(date +%s%N)

emqx_prepare(){
    mkdir -p ${PACKAGE_PATH}

    if [ ! -d "/paho-mqtt-testing" ]; then
        git clone -b develop-4.0 https://github.com/emqx/paho.mqtt.testing.git /paho-mqtt-testing
    fi
    pip3 install pytest
}

emqx_test(){
    cd ${PACKAGE_PATH}

    for var in $(ls $PACKAGE_PATH/${EMQX_NAME}-*);do
        case ${var##*.} in
            "zip")
                zipname=`basename ${PACKAGE_PATH}/${EMQX_NAME}-${SYSTEM}-*.zip`
                mkdir -p ${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}
                unzip -q ${PACKAGE_PATH}/$zipname -d ${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}
                sed -i "/zone.external.server_keepalive/c zone.external.server_keepalive = 60" ${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}/emqx/etc/emqx.conf 
                sed -i "/mqtt.max_topic_alias/c mqtt.max_topic_alias = 10" ${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}/emqx/etc/emqx.conf

                if [ ! -z $(echo ${EMQX_DEPS_DEFAULT_VSN#v} | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?-(alpha|beta|rc)\.[0-9]") ]; then
                    if [ ! -d ${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}/emqx/lib/emqx-${EMQX_DEPS_DEFAULT_VSN#v} ] || [ ! -d ${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}/emqx/releases/${EMQX_DEPS_DEFAULT_VSN#v} ] ;then
                        echo "emqx zip version error"
                        exit 1
                    fi
                fi

                echo "running ${packagename} start"
                ${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}/emqx/bin/emqx start
                IDLE_TIME=0
                while [ -z "$(${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}/emqx/bin/emqx_ctl status |grep 'is running'|awk '{print $1}')" ]
                do
                    if [ $IDLE_TIME -gt 10 ]
                    then
                        echo "emqx running error"
                        exit 1
                    fi
                    sleep 10
                    IDLE_TIME=$((IDLE_TIME+1))
                done
                pytest -v /paho-mqtt-testing/interoperability/test_client/V5/test_connect.py::test_basic
                ${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}/emqx/bin/emqx stop
                echo "running ${packagename} stop"
                rm -rf ${PACKAGE_PATH}/${SYSTEM}/${EMQX_NAME}/emqx
                rm -rf ${PACKAGE_PATH}/${SYSTEM}
            ;;
            "deb")
                if [ $SYSTEM == 'debian7' ];then
                    echo "Skip the debian7 deb package test"
                    continue
                fi
                packagename=`basename ${PACKAGE_PATH}/${EMQX_NAME}-${SYSTEM}-*.deb`
                dpkg -i ${PACKAGE_PATH}/$packagename
                if [ $(dpkg -l |grep emqx |awk '{print $1}') != "ii" ]
                then
                    echo "package install error"
                    exit 1
                fi
                
                echo "running ${packagename} start"
                running_test 
                echo "running ${packagename} stop"

                dpkg -r ${EMQX_NAME} 
                if [ $(dpkg -l |grep emqx |awk '{print $1}') != "rc" ]
                then
                    echo "package remove error"
                    exit 1
                fi

                dpkg -P ${EMQX_NAME}
                if [ ! -z "$(dpkg -l |grep emqx)" ]
                then
                    echo "package uninstall error"
                    exit 1
                fi
            ;;
            "rpm")
                packagename=`basename ${PACKAGE_PATH}/${EMQX_NAME}-${SYSTEM}-*.rpm`
                rpm -ivh ${PACKAGE_PATH}/$packagename
                if [ -z $(rpm -q emqx | grep -o emqx) ];then
                    echo "package install error"
                    exit 1
                fi
                
                echo "running ${packagename} start"
                running_test 
                echo "running ${packagename} stop"
                
                rpm -e ${EMQX_NAME}
                if [ "$(rpm -q emqx)" != "package emqx is not installed" ];then
                    echo "package uninstall error"
                    exit 1
                fi  
            ;;

        esac
    done
}

running_test(){
    if [ ! -z $(echo ${EMQX_DEPS_DEFAULT_VSN#v} | grep -oE "[0-9]+\.[0-9]+(\.[0-9]+)?-(alpha|beta|rc)\.[0-9]") ]; then
        if [ ! -d /usr/lib/emqx/lib/emqx-${EMQX_DEPS_DEFAULT_VSN#v} ] || [ ! -d /usr/lib/emqx/releases/${EMQX_DEPS_DEFAULT_VSN#v} ];then
            echo "emqx package version error"
            exit 1
        fi
    fi

    sed -i "/zone.external.server_keepalive/c zone.external.server_keepalive = 60" /etc/emqx/emqx.conf
    sed -i "/mqtt.max_topic_alias/c mqtt.max_topic_alias = 10" /etc/emqx/emqx.conf

    emqx start
    IDLE_TIME=0
    while [ -z "$(emqx_ctl status |grep 'is running'|awk '{print $1}')" ]
    do
        if [ $IDLE_TIME -gt 10 ]
        then
            echo "emqx running error"
            exit 1
        fi
        sleep 10
        IDLE_TIME=$((IDLE_TIME+1))
    done
    pytest -v /paho-mqtt-testing/interoperability/test_client/V5/test_connect.py::test_basic
    emqx stop || kill $(ps -ef |grep emqx | grep beam.smp |awk '{print $2}')

    if [ $(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/"//g') = ubuntu ] \
    || [ $(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/"//g') = debian ] \
    || [ $(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/"//g') = raspbian ];then
        service emqx start
        IDLE_TIME=0
        while [ -z "$(emqx_ctl status |grep 'is running'|awk '{print $1}')" ]
        do
            if [ $IDLE_TIME -gt 10 ]
            then
                echo "emqx service error"
                exit 1
            fi
            sleep 10
            IDLE_TIME=$((IDLE_TIME+1))
        done
        service emqx stop
    fi
}

emqx_prepare
emqx_test
