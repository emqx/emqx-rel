#!/bin/bash
make -C ../
ct_run -spec emqx.spec -pa ../deps/*/ebin ../deps/*/test
