PROJECT = emqx-rel
PROJECT_DESCRIPTION = Release Project for EMQ X Broker
PROJECT_VERSION = 3.0

DEPS += emqx emqx_retainer emqx_recon emqx_reloader emqx_dashboard emqx_management \
		emqx_auth_clientid emqx_auth_username emqx_auth_ldap emqx_auth_http \
        emqx_auth_mysql emqx_auth_pgsql emqx_auth_redis emqx_auth_mongo \
        emqx_sn emqx_coap emqx_lwm2m emqx_stomp emqx_plugin_template emqx_web_hook \
        emqx_auth_jwt emqx_statsd emqx_delayed_publish emqx_lua_hook

# emqx and plugins
dep_emqx                 = git-emqx https://github.com/emqx/emqx emqx30
dep_emqx_retainer        = git-emqx https://github.com/emqx/emqx-retainer emqx30
dep_emqx_recon           = git-emqx https://github.com/emqx/emqx-recon emqx30
dep_emqx_reloader        = git-emqx https://github.com/emqx/emqx-reloader emqx30
dep_emqx_dashboard       = git-emqx https://github.com/emqx/emqx-dashboard emqx30
dep_emqx_management      = git-emqx https://github.com/emqx/emqx-management emqx30
dep_emqx_statsd          = git-emqx https://github.com/emqx/emqx-statsd emqx30
dep_emqx_delayed_publish = git-emqx https://github.com/emqx/emqx-delayed-publish emqx30

# emq auth/acl plugins
dep_emqx_auth_clientid = git-emqx https://github.com/emqx/emqx-auth-clientid emqx30
dep_emqx_auth_username = git-emqx https://github.com/emqx/emqx-auth-username emqx30
dep_emqx_auth_ldap     = git-emqx https://github.com/emqx/emqx-auth-ldap emqx30
dep_emqx_auth_http     = git-emqx https://github.com/emqx/emqx-auth-http emqx30
dep_emqx_auth_mysql    = git-emqx https://github.com/emqx/emqx-auth-mysql emqx30
dep_emqx_auth_pgsql    = git-emqx https://github.com/emqx/emqx-auth-pgsql emqx30
dep_emqx_auth_redis    = git-emqx https://github.com/emqx/emqx-auth-redis emqx30
dep_emqx_auth_mongo    = git-emqx https://github.com/emqx/emqx-auth-mongo emqx30
dep_emqx_auth_jwt      = git-emqx https://github.com/emqx/emqx-auth-jwt emqx30

# mqtt-sn, coap and stomp
dep_emqx_sn    = git-emqx https://github.com/emqx/emqx-sn emqx30
dep_emqx_coap  = git-emqx https://github.com/emqx/emqx-coap emqx30
dep_emqx_lwm2m = git-emqx https://github.com/emqx/emqx-lwm2m emqx30
dep_emqx_stomp = git-emqx https://github.com/emqx/emqx-stomp emqx30

# plugin template
dep_emqx_plugin_template = git-emqx https://github.com/emqx/emq-plugin-template emqx30

# web_hook
dep_emqx_web_hook  = git-emqx https://github.com/emqx/emqx-web-hook emqx30
dep_emqx_lua_hook  = git-emqx https://github.com/emqx/emqx-lua-hook emqx30

define dep_fetch_git-emqx
	git clone -q --depth 1 -b $(call dep_commit,$(1)) -- $(call dep_repo,$(1)) $(DEPS_DIR)/$(call dep_name,$(1)); \
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
