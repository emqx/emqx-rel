#!/bin/bash
make -C ../
ct_run -spec emqtt.spec -pa ../deps/*/ebin ../deps/*/test
