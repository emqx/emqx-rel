#!/bin/sh
set -ex
export EMQX_NAME=${EMQX_NAME:-"emqx"}
export REL_PATH=${REL_PATH:-"../../.."}
export PACKAGE_PATH="${REL_PATH}/_packages/${EMQX_NAME}"

emqx_prepare(){
    mkdir -p ${PACKAGE_PATH}

    if [ ! -d "/paho-mqtt-testing" ]; then
        git clone -b develop-4.0 https://github.com/emqx/paho.mqtt.testing.git /paho-mqtt-testing
    fi
    pip3 install pytest
}

emqx_build_to_zip(){
    cd ${REL_PATH}
    pkg=${EMQX_NAME}-${SYSTEM}-${EMQX_DEPS_DEFAULT_VSN}.zip
    make ${EMQX_NAME}
    cd _build/emqx*/rel/ && zip -rq $pkg emqx && mv $pkg ${PACKAGE_PATH}
}

emqx_build_to_pkg(){
    cd ${REL_PATH}
    make ${EMQX_NAME}-pkg
}

emqx_test(){
    cd ${PACKAGE_PATH}

    for var in $(ls $PACKAGE_PATH/${EMQX_NAME}-*);do
        case ${var##*.} in
            "zip")
                zipname=`basename ${PACKAGE_PATH}/${EMQX_NAME}-${SYSTEM}-*.zip`
                unzip -q ${PACKAGE_PATH}/$zipname -d ${PACKAGE_PATH}
                sed -i "/zone.external.server_keepalive/c zone.external.server_keepalive = 60" ${PACKAGE_PATH}/emqx/etc/emqx.conf 
                sed -i "/mqtt.max_topic_alias/c mqtt.max_topic_alias = 10" ${PACKAGE_PATH}/emqx/etc/emqx.conf

                if [[ ! -z $(echo $EMQX_DEPS_DEFAULT_VSN | grep -oE "v[0-9]+\.[0-9]+(\.[0-9]+)?-(alpha|beta|rc)\.[0-9]") ]]; then
                    if [[ ! -d ${PACKAGE_PATH}/emqx/lib/emqx-${EMQX_DEPS_DEFAULT_VSN#v} ]] || [[ ! -d ${PACKAGE_PATH}/emqx/releases/${EMQX_DEPS_DEFAULT_VSN} ]] ;then
                        echo "emqx zip version error"
                        exit 1
                    fi
                fi

                ${PACKAGE_PATH}/emqx/bin/emqx start
                IDLE_TIME=0
                while [[ -z "$(${PACKAGE_PATH}/emqx/bin/emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
                do
                    if [[ $IDLE_TIME -gt 10 ]]
                    then
                        echo "emqx running error"
                        exit 1
                    fi
                    sleep 10
                    IDLE_TIME=$((IDLE_TIME+1))
                done
                echo "running ${packagename} start"
                pytest -v /paho-mqtt-testing/interoperability/test_client/V5/test_connect.py::test_basic
                ${PACKAGE_PATH}/emqx/bin/emqx stop
                echo "running ${packagename} start"
                rm -rf ${PACKAGE_PATH}/emqx
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
                if [[ ! -z "$(dpkg -l |grep emqx)" ]]
                then
                    echo "package uninstall error"
                    exit 1
                fi
            ;;
            "rpm")
                packagename=`basename ${PACKAGE_PATH}/${EMQX_NAME}-${SYSTEM}-*.rpm`
                rpm -ivh ${PACKAGE_PATH}/$packagename
                if [[ $(rpm -q ${EMQX_NAME}) != emqx* ]];then
                    echo "package install error"
                    exit 1
                fi
                
                echo "running ${packagename} start"
                running_test 
                echo "running ${packagename} stop"
                
                rpm -e ${EMQX_NAME}
                if [[ $(rpm -q emqx) == emqx* ]];then
                    echo "package uninstall error"
                    exit 1
                fi  
            ;;

        esac
    done
}

running_test(){
    if [[ ! -z $(echo $EMQX_DEPS_DEFAULT_VSN | grep -oE "v[0-9]+\.[0-9]+(\.[0-9]+)?-(alpha|beta|rc)\.[0-9]") ]]; then
        if [[ ! -d /usr/lib/emqx/lib/emqx-${EMQX_DEPS_DEFAULT_VSN#v} ]] || [[ ! -d /usr/lib/emqx/releases/${EMQX_DEPS_DEFAULT_VSN} ]];then
            echo "emqx package version error"
            exit 1
        fi
    fi

    sed -i "/zone.external.server_keepalive/c zone.external.server_keepalive = 60" /etc/emqx/emqx.conf
    sed -i "/mqtt.max_topic_alias/c mqtt.max_topic_alias = 10" /etc/emqx/emqx.conf

    emqx start
    IDLE_TIME=0
    while [[ -z "$(emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
    do
        if [[ $IDLE_TIME -gt 10 ]]
        then
            echo "emqx running error"
            exit 1
        fi
        sleep 10
        IDLE_TIME=$((IDLE_TIME+1))
    done
    pytest -v /paho-mqtt-testing/interoperability/test_client/V5/test_connect.py::test_basic
    emqx stop

    if [ $(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/"//g') = ubuntu ] \
    || [ $(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/"//g') = debian ] \
    || [ $(sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/"//g') = raspbian ];then
        service emqx start
        IDLE_TIME=0
        while [[ -z "$(emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
        do
            if [[ $IDLE_TIME -gt 10 ]]
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
emqx_build_to_zip
emqx_build_to_pkg
emqx_test
