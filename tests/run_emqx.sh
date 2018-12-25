#!/bin/bash

make -C .. deps

while IFS='' read line || [[ -n $line ]]; do
    echo ============start test $line===============
    make -C ../deps/$line/ tests </dev/null
done < $1
