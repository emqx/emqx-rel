## shallow clone for speed

REBAR_GIT_CLONE_OPTIONS += --depth 1
export REBAR_GIT_CLONE_OPTIONS

REBAR = rebar3
all: build

build: emqx

emqx_edge:
	rebar3 as emqx_edge release

emqx_edge_pkg:
	rebar3 as emqx_edge_pkg release

emqx:
	rebar3 as emqx release

emqx_pkg:
	rebar3 as emqx_pkg release

clean: distclean

distclean:
	@rm -rf _build
	@rm -f data/app.*.config
	@rm -f data/vm.*.args
