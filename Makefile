## shallow clone for speed

REBAR_GIT_CLONE_OPTIONS += --depth 1
export REBAR_GIT_CLONE_OPTIONS

REBAR = rebar3
all: build

build: cloud_dev

edge_dev:
	rebar3 as edge_dev release

edge_pkg:
	rebar3 as edge_pkg release

cloud_dev:
	rebar3 as cloud_dev release

cloud_pkg:
	rebar3 as cloud_pkg release

clean: distclean

distclean:
	@rm -rf _build
	@rm -f data/app.*.config
	@rm -f data/vm.*.args
