#!/bin/bash

make -C .. deps

while IFS='' read line || [[ -n $line ]]; do
    echo ============start test $line===============
    if [ $line == "emqx_auth_mysql" ];then
        sed -i "/auth.mysql.server/c auth.mysql.server = mysql_server:3306" ../deps/$line/etc/emqx_auth_mysql.conf 
    fi
    if [ $line == "emqx_auth_redis" ];then
        sed -i "/auth.redis.server/c auth.redis.server = redis_server:6379" ../deps/$line/etc/emqx_auth_redis.conf 
    fi
    if [ $line == "emqx_auth_mongo" ];then
        sed -i "/auth.mongo.server/c auth.mongo.server = mongo_server:27017" ../deps/$line/etc/emqx_auth_mongo.conf 
    fi
    if [ $line == "emqx_auth_pgsql" ];then
        sed -i "/auth.pgsql.server/c auth.pgsql.server = pgsql_server:5432" ../deps/$line/etc/emqx_auth_pgsql.conf 
    fi
    if [ $line == "emqx_auth_ldap" ];then
        sed -i "/auth.ldap.server/c auth.ldap.server = ldap_server:3306" ../deps/$line/etc/emqx_auth_ldap.conf 
    fi
    rm -rf ../deps/$line/deps
    rm -rf ../deps/$line/erlang.mk
    make -C ../deps/$line/ tests </dev/null
    mkdir -p logs/$line
    cp -r ../deps/$line/logs/* logs/$line
done < $1
