# emqx-rel


The Release Project for EMQX Broker.

NOTICE: Requires Erlang/OTP 21.3 .. 22 to build since EMQX 3.2

EMQX no longer uses this repository since version 4.3. Use https://github.com/emqx/emqx/ instead.


There are 4 target profiles for building emqx-rel: emqx, emqx-pkg, emqx-edge,and emqx-edge-pkg. The default target profile is emqx. User can build specified target release by execute command `make ${target-release}` in emqx_rel.

## rebar3

This project has rebar3 (compiled from OTP 21.3) included.

## Build on Linux/Unix/Mac

```shell
$ git clone https://github.com/emqx/emqx-rel.git emqx-rel
$ cd emqx-rel
$ git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
$ make
$ ./_build/emqx/rel/emqx/bin/emqx console
```

## Build rpm or deb package on Linux
```shell
$ git clone https://github.com/emqx/emqx-rel.git emqx-rel
$ cd emqx-rel
$ git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
$ make emqx-pkg
$ ls _packages/emqx
```

## Build docker image
```shell
$ git clone https://github.com/emqx/emqx-rel.git emqx-rel
$ cd emqx-rel
$ git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
$ TARGET=emqx/emqx make docker
```

## Build on Windows

```powershell
git clone -b v4.0.0 https://github.com/emqx/emqx-rel.git emqx-rel
cd emqx-rel
make
cd _build\emqx\rel\emqx
bin\emqx console
```

## Build with elixir plugins

Modify the rebar.config.

```erlang

{elixir_deps,
   [ {plugin_name, {git, "url_of_plugin", {tag, "tag_of_plugin"}}}
   , ....
   ....
   ]
}

......
......

{elixir_relx_apps,
    [ app_name1
    , app_name2]}.

```

Due to the limit of the `rebar3_elixir_compile`, users have to specify all the
dependencies of the the elixir plugin in rebar.config in emqx-rel.

## Start with epmd

For now, emqx starts without epmd by default. If you want to run emqx with epmd,
you should set the environment variable $WITH_EPMD with any value you want, for example, execute `export $WITH_EPMD=true` in your shell, then run emqx, epmd will start soon afterwards.

# Test

```bash
make ct
```

# License

Apache License Version 2.0

# Author

EMQX Team.
