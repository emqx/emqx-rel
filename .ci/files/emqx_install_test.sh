#!/bin/bash
packagespath=${buildlocation}

if [[ $ostype == centos* ]]
then
    packagename=`basename $packagespath/emqx-$ostype-$version*.rpm`
    rpm -ivh $packagespath/$packagename
    if [[ $(rpm -q emqx) != emqx* ]]
    then
        echo "package install error"
    exit 1
    fi

    emqx start
    if [[ -z "$(emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
    then
        echo "emqx running error"
        exit 1
    fi
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

    rpm -e emqx
    if [[ $(rpm -q emqx) == emqx* ]]
    then
        echo "package uninstall error"
        exit 1
    fi 
else
    packagename=`basename $packagespath/emqx-$ostype-$version*.deb`
    dpkg -i $packagespath/$packagename
    if [ $(dpkg -l |grep emqx |awk '{print $1}') != "ii" ]
    then
        echo "package install error"
        exit 1
    fi

    emqx start
    if [[ -z "$(emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
    then
        echo "emqx running error"
        exit 1
    fi
    emqx stop

    service emqx start
    if [[ -z "$(emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
    then
        echo "emqx service error"
        exit 1
    fi
    service emqx stop

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
fi

zipname=`basename emqx-$ostype-$version*.zip`
unzip $packagespath/$zipname -d $packagespath
cd $packagespath/emqx
$packagespath/emqx/bin/emqx start
if [[ -z "$($packagespath/emqx/bin/emqx_ctl status |grep 'is running'|awk '{print $1}')" ]]
then
    echo "emqx running error"
    exit 1
fi
$packagespath/emqx/bin/emqx stop
rm -rf $packagespath/emqx