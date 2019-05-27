#!/bin/bash
EMQX_DEPS_DEFAULT_VSN=`[[ $(git rev-parse --abbrev-ref HEAD) == "HEAD" ]] && git describe --always --tag || git rev-parse --abbrev-ref HEAD`
rm -rf ./emqx_auth_clientid
git clone -b $EMQX_DEPS_DEFAULT_VSN https://github.com/emqx/emqx-auth-clientid emqx_auth_clientid
cd emqx_auth_clientid && make
cd ..

while IFS='' read line || [[ -n $line ]]; do
    echo ============start test $line by $EMQX_DEPS_DEFAULT_VSN===============
    rm -rf ./deps/$line
    if [[ $line =~ "emqx" ]];then
        git clone -b $EMQX_DEPS_DEFAULT_VSN https://github.com/emqx/${line//_/-} ./deps/$line
    else
        git clone -b develop https://github.com/emqx/${line//_/-} ./deps/$line 
    fi
    if [ $line == "emqx_auth_mysql" ];then
        sed -i "/auth.mysql.server/c auth.mysql.server = mysql_server:3306" ./deps/$line/etc/emqx_auth_mysql.conf 
        echo "auth.mysql.username = root" >> ./deps/$line/etc/emqx_auth_mysql.conf
        echo "auth.mysql.password = public" >> ./deps/$line/etc/emqx_auth_mysql.conf
    fi
    if [ $line == "emqx_auth_redis" ];then
        sed -i "/auth.redis.server/c auth.redis.server = redis_server:6379" ./deps/$line/etc/emqx_auth_redis.conf 
    fi
    if [ $line == "emqx_auth_mongo" ];then
        sed -i "/auth.mongo.server/c auth.mongo.server = mongo_server:27017" ./deps/$line/etc/emqx_auth_mongo.conf 
    fi
    if [ $line == "emqx_auth_pgsql" ];then
        sed -i "/auth.pgsql.server/c auth.pgsql.server = pgsql_server:5432" ./deps/$line/etc/emqx_auth_pgsql.conf 
    fi
    if [ $line == "emqx_auth_ldap" ];then
        sed -i "/auth.ldap.servers/c auth.ldap.servers = ldap_server" ./deps/$line/etc/emqx_auth_ldap.conf 
    fi
    mkdir -p ./deps/$line/_build/test/lib
    if [ $line != "emqx" ];then
        cp -r ./emqx_auth_clientid/_build/default/lib/* ./deps/$line/_build/test/lib
    fi
    make -C ./deps/$line/ eunit </dev/null
    make -C ./deps/$line/ ct </dev/null
    mkdir -p logs/$line
    cp -r ./deps/$line/_build/test/logs/* logs/$line
done < $1
