## shallow clone for speed

REBAR_GIT_CLONE_OPTIONS += --depth 1
export REBAR_GIT_CLONE_OPTIONS

# Set this variable to a tag or branch name to use that tag/branch for all emqx repos
# export EMQX_DEPS_DEFAULT_VSN = develop

REBAR = rebar3
all: build

build: emqx

run: emqx_run

emqx:
	rebar3 as dev,cloud release

emqx_clean:
	rebar3 as dev,cloud clean

emqx_run:
	rebar3 as dev,cloud run

emqx_pkg:
	rebar3 as pkg,cloud release

emqx_pkg_clean:
	rebar3 as pkg,cloud clean

emqx_edge:
	rebar3 as dev,edge release

emqx_edge_run:
	rebar3 as dev,edge run

emqx_edge_clean:
	rebar3 as dev,edge clean

emqx_edge_pkg:
	rebar3 as pkg,edge release

emqx_edge_pkg_clean:
	rebar3 as pkg,edge clean

clean: distclean

distclean:
	@rm -rf _build
	@rm -f data/app.*.config
	@rm -f data/vm.*.args
