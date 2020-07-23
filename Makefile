## shallow clone for speed

REBAR_GIT_CLONE_OPTIONS += --depth 1
export REBAR_GIT_CLONE_OPTIONS

REBAR = $(CURDIR)/rebar3

REBAR_URL = https://s3.amazonaws.com/rebar3/rebar3

EMQX_DEPS_DEFAULT_VSN ?= ""
ifeq ($(EMQX_DEPS_DEFAULT_VSN), )
	BUILD_VERSION := $(patsubst v%,%,$(patsubst e%,%,$(shell git describe --tags --always)))
else ifeq ($(EMQX_DEPS_DEFAULT_VSN), "")
	BUILD_VERSION := $(patsubst v%,%,$(patsubst e%,%,$(shell git describe --tags --always)))
else
	BUILD_VERSION := $(patsubst v%,%,$(patsubst e%,%,$(EMQX_DEPS_DEFAULT_VSN)))
endif

PROFILE ?= emqx
PROFILES := emqx emqx-edge
PKG_PROFILES := emqx-pkg emqx-edge-pkg

CT_APPS := emqx \
           emqx_auth_clientid \
           emqx_auth_http \
           emqx_auth_jwt \
           emqx_auth_ldap \
           emqx_auth_mongo \
           emqx_auth_mysql \
           emqx_auth_pgsql \
           emqx_auth_redis \
           emqx_auth_username \
           emqx_auth_mnesia \
           emqx_sasl \
           emqx_coap \
           emqx_recon \
           emqx_dashboard \
           emqx_delayed_publish \
           emqx_lua_hook \
           emqx_lwm2m \
           emqx_management \
           emqx_retainer \
           emqx_sn \
           emqx_stomp \
           emqx_web_hook \
           emqx_bridge_mqtt \
           emqx_rule_engine \
           emqx_extension_hook \
           emqx_exproto

.PHONY: default
default: $(REBAR) $(PROFILE)

.PHONY: all
all: $(REBAR) $(PROFILES)

.PHONY: distclean
distclean: remove-build-meta-files
	@rm -rf _build
	@rm -rf _checkouts

.PHONY: distclean-deps
distclean-deps: remove-deps remove-build-meta-files

.PHONY: remove-deps
remove-deps:
	@rm -rf _build/$(PROFILE)/lib
	@rm -rf _build/$(PROFILE)/conf
	@rm -rf _build/$(PROFILE)/plugins

.PHONY: remove-build-meta-files
remove-build-meta-files:
	@rm -f data/app.*.config data/vm.*.args rebar.lock

.PHONY: $(PROFILES)
$(PROFILES:%=%) $(PROFILES:%=zip-%): $(REBAR)
ifneq ($(OS),Windows_NT)
	@ln -snf _build/$(subst zip-,,$(@))/lib ./_checkouts
endif
	@if [ $$(echo $(@) |grep edge) ];then export EMQX_DESC="EMQ X Edge";else export EMQX_DESC="EMQ X Broker"; fi; \
	if [ "$(findstring zip, $(@))" == 'zip' ];\
	then \
		tard="/tmp/emqx_untar_$$(date +%s)";\
		prof="$(subst zip-,,$(@))";\
		relpath="$$(pwd)/_build/$${prof}/rel/emqx";\
		tarball="$${relpath}/emqx-${BUILD_VERSION}.tar.gz";\
		zipball="$${relpath}/emqx-${BUILD_VERSION}-$$(uname -m).zip";\
		rm -rf "$${tard}" && mkdir -p "$${tard}/emqx";\
		BUILD_VERSION=${BUILD_VERSION} $(REBAR) as "$${prof}" tar \
		&& tar zxf "$${tarball}" -C "$${tard}/emqx" \
		&& cd "$${tard}" \
		&& zip -q -r "$${zipball}" ./emqx; cd - > /dev/null\
		&& echo "===> zipball $${zipball} created!";\
	else BUILD_VERSION=${BUILD_VERSION} $(REBAR) as $(@) release;\
	fi

.PHONY: $(PROFILES:%=relup-%)
$(PROFILES:%=relup-%): $(REBAR)
#ifneq ($(OS),Windows_NT)
	BUILD_VERSION=${BUILD_VERSION} PROFILE=$(@:relup-%=%) ./gen_appups.sh \
	&& $(REBAR) as $(@:relup-%=%) relup
#endif

.PHONY: $(PROFILES:%=build-%)
$(PROFILES:%=build-%): $(REBAR)
	BUILD_VERSION=${BUILD_VERSION} $(REBAR) as $(@:build-%=%) compile

.PHONY: deps-all
deps-all: $(REBAR) $(PROFILES:%=deps-%) $(PKG_PROFILES:%=deps-%)

.PHONY: $(PROFILES:%=deps-%)
$(PROFILES:%=deps-%): $(REBAR)
	$(REBAR) as $(@:deps-%=%) get-deps

.PHONY: $(PKG_PROFILES:%=deps-%)
$(PKG_PROFILES:%=deps-%): $(REBAR) $(PKG_PROFILES:%=deps-%)
	$(REBAR) as $(@:deps-%=%) get-deps

.PHONY: run $(PROFILES:%=run-%)
run: run-$(PROFILE)
$(PROFILES:%=run-%): $(REBAR)
ifneq ($(OS),Windows_NT)
	@ln -snf _build/$(@:run-%=%)/lib ./_checkouts
endif
	BUILD_VERSION=${BUILD_VERSION} $(REBAR) as $(@:run-%=%) run

.PHONY: clean $(PROFILES:%=clean-%)
clean: $(PROFILES:%=clean-%)
$(PROFILES:%=clean-%): $(REBAR)
	@rm -rf _build/$(@:clean-%=%)
	@rm -rf _build/$(@:clean-%=%)+test

.PHONY: $(PROFILES:%=checkout-%)
$(PROFILES:%=checkout-%): $(REBAR) build-$(PROFILE)
	ln -s -f _build/$(@:checkout-%=%)/lib ./_checkouts

# Checkout current profile
.PHONY: checkout
checkout:
	@ln -s -f _build/$(PROFILE)/lib ./_checkouts

# Run ct for an app in current profile
.PHONY: $(REBAR) $(CT_APPS:%=ct-%)
ct: $(CT_APPS:%=ct-%)
$(CT_APPS:%=ct-%): checkout-$(PROFILE)
	-make -C _build/emqx/lib/$(@:ct-%=%) ct
	@mkdir -p tests/logs/$(@:ct-%=%)
	@if [ -d _build/emqx/lib/$(@:ct-%=%)/_build/test/logs ]; then cp -r _build/emqx/lib/$(@:ct-%=%)/_build/test/logs/* tests/logs/$(@:ct-%=%); fi

$(REBAR):
ifneq ($(wildcard rebar3),rebar3)
	@curl -Lo rebar3 $(REBAR_URL) || wget $(REBAR_URL)
endif
	@chmod a+x rebar3

# Build packages
.PHONY: $(PKG_PROFILES)
$(PKG_PROFILES:%=%): $(REBAR)
	ln -snf _build/$(@)/lib ./_checkouts
	@if [ $$(echo $(@) |grep edge) ];then export EMQX_DESC="EMQ X Edge";else export EMQX_DESC="EMQ X Broker"; fi;\
	BUILD_VERSION=${BUILD_VERSION} $(REBAR) as $(@) release
	EMQX_REL=$$(pwd) EMQX_BUILD=$(@) make -C deploy/packages

# Build docker image
.PHONY: $(PROFILES:%=%-docker-build)
$(PROFILES:%=%-docker-build): $(PKG_PROFILES:%=deps-%)
	@if [ ! -z `echo $(@) |grep -oE edge` ]; then \
		TARGET=emqx/emqx-edge make -C deploy/docker; \
	else \
		TARGET=emqx/emqx make -C deploy/docker; \
	fi;

# Save docker images
.PHONY: $(PROFILES:%=%-docker-save)
$(PROFILES:%=%-docker-save):
	@if [ ! -z `echo $(@) |grep -oE edge` ]; then \
		TARGET=emqx/emqx-edge make -C deploy/docker save; \
	else \
		TARGET=emqx/emqx make -C deploy/docker save; \
	fi;

# Push docker image
.PHONY: $(PROFILES:%=%-docker-push)
$(PROFILES:%=%-docker-push):
	@if [ ! -z `echo $(@) |grep -oE edge` ]; then \
		TARGET=emqx/emqx-edge make -C deploy/docker push; \
		TARGET=emqx/emqx-edge make -C deploy/docker manifest_list; \
	else \
		TARGET=emqx/emqx make -C deploy/docker push; \
		TARGET=emqx/emqx make -C deploy/docker manifest_list; \
	fi;

# Clean docker image
.PHONY: $(PROFILES:%=%-docker-clean)
$(PROFILES:%=%-docker-clean):
	@if [ ! -z `echo $(@) |grep -oE edge` ]; then \
		TARGET=emqx/emqx-edge make -C deploy/docker clean; \
	else \
		TARGET=emqx/emqx make -C deploy/docker clean; \
	fi;
