PROJECT = emqx-rel
PROJECT_DESCRIPTION = Release Project for EMQ X Broker
PROJECT_VERSION = 3.0

DEPS += emqx emqx_retainer emqx_recon emqx_reloader emqx_dashboard emqx_management \
		emqx_auth_clientid emqx_auth_username emqx_auth_ldap emqx_auth_http \
        emqx_auth_mysql emqx_auth_pgsql emqx_auth_redis emqx_auth_mongo \
        emqx_sn emqx_coap emqx_lwm2m emqx_stomp emqx_plugin_template emqx_web_hook \
        emqx_auth_jwt emqx_statsd emqx_delayed_publish emqx_lua_hook

UrlPrefix ?= https://github.com/emqx

VSN ?= emqx30

# emqx and plugins
dep_emqx                 = git-emqx emqx $(VSN)
dep_emqx_retainer        = git-emqx emqx-retainer $(VSN)
dep_emqx_recon           = git-emqx emqx-recon $(VSN)
dep_emqx_reloader        = git-emqx emqx-reloader $(VSN)
dep_emqx_dashboard       = git-emqx emqx-dashboard $(VSN)
dep_emqx_management      = git-emqx emqx-management $(VSN)
dep_emqx_statsd          = git-emqx emqx-statsd $(VSN)
dep_emqx_delayed_publish = git-emqx emqx-delayed-publish $(VSN)

# emq auth/acl plugins
dep_emqx_auth_clientid = git-emqx emqx-auth-clientid $(VSN)
dep_emqx_auth_username = git-emqx emqx-auth-username $(VSN)
dep_emqx_auth_ldap     = git-emqx emqx-auth-ldap $(VSN)
dep_emqx_auth_http     = git-emqx emqx-auth-http $(VSN)
dep_emqx_auth_mysql    = git-emqx emqx-auth-mysql $(VSN)
dep_emqx_auth_pgsql    = git-emqx emqx-auth-pgsql $(VSN)
dep_emqx_auth_redis    = git-emqx emqx-auth-redis $(VSN)
dep_emqx_auth_mongo    = git-emqx emqx-auth-mongo $(VSN)
dep_emqx_auth_jwt      = git-emqx emqx-auth-jwt $(VSN)

# mqtt-sn, coap and stomp
dep_emqx_sn    = git-emqx emqx-sn $(VSN)
dep_emqx_coap  = git-emqx emqx-coap $(VSN)
dep_emqx_lwm2m = git-emqx emqx-lwm2m $(VSN)
dep_emqx_stomp = git-emqx emqx-stomp $(VSN)

# plugin template
dep_emqx_plugin_template = git-emqx emq-plugin-template $(VSN)

# web_hook
dep_emqx_web_hook  = git-emqx emqx-web-hook $(VSN)
dep_emqx_lua_hook  = git-emqx emqx-lua-hook $(VSN)

define dep_fetch_git-emqx
	git clone --depth 1 -b $(call dep_commit,$(1)) -- $(UrlPrefix)/$(call dep_repo,$(1)) $(DEPS_DIR)/$(call dep_name,$(1)); \
	cd $(DEPS_DIR)/$(call dep_name,$(1));
endef

# Add this dependency before including erlang.mk
all:: OTP_21_OR_NEWER

# COVER = true
include erlang.mk

# Fail fast in case older than OTP 21
.PHONY: OTP_21_OR_NEWER
OTP_21_OR_NEWER:
	@erl -noshell -eval "R = list_to_integer(erlang:system_info(otp_release)), halt(if R >= 21 -> 0; true -> 1 end)"

# Compile options
ERLC_OPTS += +warn_export_all +warn_missing_spec +warn_untyped_record

plugins:
	@rm -rf rel
	@mkdir -p rel/conf/plugins/ rel/schema/
	@for conf in $(DEPS_DIR)/*/etc/*.conf* ; do \
		if [ "emqx.conf" = "$${conf##*/}" ] ; then \
			cp $${conf} rel/conf/ ; \
		elif [ "acl.conf" = "$${conf##*/}" ] ; then \
			cp $${conf} rel/conf/ ; \
		elif [ "ssl_dist.conf" = "$${conf##*/}" ] ; then \
			cp $${conf} rel/conf/ ; \
		else \
			cp $${conf} rel/conf/plugins ; \
		fi ; \
	done
	@for schema in $(DEPS_DIR)/*/priv/*.schema ; do \
		cp $${schema} rel/schema/ ; \
	done

app:: plugins
