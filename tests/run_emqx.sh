#!/bin/bash

make -C .. deps

while IFS='' read line || [[ -n $line ]]; do
    echo ============start test $line===============
    rm -rf ../deps/$line/deps
    rm -rf ../deps/$line/erlang.mk
    make -C ../deps/$line/ tests </dev/null
done < $1
