## shallow clone for speed

REBAR_GIT_CLONE_OPTIONS += --depth 1
export REBAR_GIT_CLONE_OPTIONS

export EMQX_DEPS_DEFAULT_VSN = develop

REBAR = rebar3
all: build

build: emqx

emqx:
	rebar3 as emqx release

emqx_clean:
	rebar3 as emqx clean

emqx_pkg_clean:
	rebar3 as emqx_pkg clean

emqx_edge:
	rebar3 as emqx_edge release

emqx_edge_clean:
	rebar3 as emqx_edge clean

emqx_edge_pkg:
	rebar3 as emqx_edge_pkg release

emqx_edge_pkg_clean:
	rebar3 as emqx_edge_pkg clean

clean: distclean

distclean:
	@rm -rf _build
	@rm -f data/app.*.config
	@rm -f data/vm.*.args
