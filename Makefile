## shallow clone for speed

REBAR_GIT_CLONE_OPTIONS += --depth 1
export REBAR_GIT_CLONE_OPTIONS

EMQX_DEPS_DEFAULT_VSN ?= develop
export EMQX_DEPS_DEFAULT_VSN

REBAR := rebar3

PROFILE ?= emqx
PROFILES := emqx emqx_pkg emqx_edge emqx_edge_pkg

CT_APPS := emqx_auth_jwt emqx_auth_mysql emqx_auth_username \
		emqx_delayed_publish emqx_management emqx_recon emqx_rule_enginex \
		emqx_stomp emqx_auth_clientid  emqx_auth_ldap   emqx_auth_pgsql \
		emqx_coap emqx_lua_hook emqx_passwd emqx_reloader emqx_sn \
		emqx_web_hook emqx_auth_http emqx_auth_mongo emqx_auth_redis \
		emqx_dashboard emqx_lwm2m emqx_psk_file emqx_retainer emqx_statsd

.PHONY: all
all:
	$(REBAR) as $(PROFILE) release

.PHONY: distclean
distclean:
	@rm -rf _build
	@rm -f data/app.*.config data/vm.*.args rebar.lock

.PHONY: $(PROFILES)
$(PROFILES:%=%):
	$(REBAR) as $(@) release

.PHONY: $(PROFILES:%=build-%)
$(PROFILES:%=build-%):
	$(REBAR) as $(@:build-%=%) compile

.PHONY: run $(PROFILES:%=run-%)
run: $(PROFILES:%=run-%)
$(PROFILES:%=run-%):
	$(REBAR) as $(@:run-%=%) run

.PHONY: clean $(PROFILES:%=clean-%)
clean: $(PROFILES:%=clean-%)
$(PROFILES:%=clean-%):
	@rm -rf _build/$(@:clean-%=%)
	@rm -rf _build/$(@:clean-%=%)+test

.PHONY: $(PROFILES:%=checkout-%)
$(PROFILES:%=checkout-%): build-$(PROFILE)
	ln -s -f _build/$(@:checkout-%=%)/lib ./_checkouts

# Checkout current profile
.PHONY: checkout
checkout:
	@ln -s -f _build/$(PROFILE)/lib ./_checkouts

# Run ct for an app in current profile
.PHONY: $(CT_APPS:%=ct-%)
ct: $(CT_APPS:%=ct-%)
$(CT_APPS:%=ct-%): checkout-$(PROFILE)
	$(REBAR) as $(PROFILE) ct --verbose --dir _checkouts/$(@:ct-%=%)/test --verbosity 50

