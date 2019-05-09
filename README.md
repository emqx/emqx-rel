emqx-rel
========

The Release Project for EMQ X Broker.

NOTICE: Requires Erlang/OTP R21.0+ to build since EMQ X R3.0

There are 4 target profiles for building emqx-rel: emqx, emqx_pkg, emqx_edge,and emqx_edge_pkg. The default target profile is emqx. User can build specified target release by execute command `make ${target-release}` in emqx_rel.

Build on Linux/Unix/Mac
-----------------------

```
git clone https://github.com/emqx/emqx-rel.git emqx-rel
cd emqx-rel && make
cd _build/emqx/rel/emqx && ./bin/emqx console
```

Build Docker Image
------------------

```
git clone https://github.com/emqx/emqx-docker.git emqx_docker
cd emqx_docker && docker build -t emqx:latest .
```

Build on Windows
----------------

Install Erlang/OTP-R21.0 and MSYS2-x86_64 for erlang.mk:

```
https://erlang.mk/guide/installation.html#_on_windows
```

Clone and build the EMQ X Broker with erlang.mk:

```
git clone https://github.com/emqx/emqx-rel.git emqx-rel
cd emqx-rel
make
cd _build\emqx\rel\emqx
bin\emqx console
```

License
-------

Apache License Version 2.0

Author
------

EMQ X Team.
