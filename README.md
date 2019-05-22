# emqx-rel


The Release Project for EMQ X Broker.

NOTICE: Requires Erlang/OTP R21.0+ to build since EMQ X R3.2


There are 4 target profiles for building emqx-rel: emqx, emqx_pkg, emqx_edge,and emqx_edge_pkg. The default target profile is emqx. User can build specified target release by execute command `make ${target-release}` in emqx_rel.

## Install Erlang/OTP-R21.3 and rebar3

Read the section below and install rebar3

```
https://www.rebar3.org/docs/getting-started#section-installing-from-source
```

## Build on Linux/Unix/Mac

```
git clone https://github.com/emqx/emqx-rel.git emqx-rel
cd emqx-rel && make
./_build/emqx/rel/emqx/bin/emqx console
```

## Build on Windows

```
git clone https://github.com/emqx/emqx-rel.git emqx-rel
cd emqx-rel
make
cd _build\emqx\rel\emqx
bin\emqx console
```

# Test

```bash
make ct
```

# License

Apache License Version 2.0

# Author

EMQ X Team.
