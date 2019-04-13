PROJECT = emqx-rel
PROJECT_DESCRIPTION = Release Project for EMQ X Broker

RELX_TAR = 0

NO_AUTOPATCH = cuttlefish

EMQX_DEPS_DEFAULT_VSN = v3.1-rc.2

DEPS += emqx emqx_retainer emqx_recon emqx_reloader emqx_dashboard emqx_management \
		emqx_auth_clientid emqx_auth_username emqx_auth_ldap emqx_auth_http \
        emqx_auth_mysql emqx_auth_pgsql emqx_auth_redis emqx_auth_mongo \
        emqx_sn emqx_coap emqx_lwm2m emqx_stomp emqx_plugin_template emqx_web_hook \
        emqx_auth_jwt emqx_statsd emqx_delayed_publish emqx_lua_hook emqx_psk_file \
        emqx_rule_engine

# emqx and plugins
dep_emqx            = git-emqx https://github.com/emqx/emqx win30
dep_emqx_retainer   = git-emqx https://github.com/emqx/emqx-retainer $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_recon      = git-emqx https://github.com/emqx/emqx-recon $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_reloader   = git-emqx https://github.com/emqx/emqx-reloader $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_dashboard  = git-emqx https://github.com/emqx/emqx-dashboard $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_management = git-emqx https://github.com/emqx/emqx-management $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_statsd     = git-emqx https://github.com/emqx/emqx-statsd $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_delayed_publish = git-emqx https://github.com/emqx/emqx-delayed-publish $(EMQX_DEPS_DEFAULT_VSN)

# emq auth/acl plugins
dep_emqx_auth_clientid = git-emqx https://github.com/emqx/emqx-auth-clientid $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_auth_username = git-emqx https://github.com/emqx/emqx-auth-username $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_auth_ldap     = git-emqx https://github.com/emqx/emqx-auth-ldap $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_auth_http     = git-emqx https://github.com/emqx/emqx-auth-http $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_auth_mysql    = git-emqx https://github.com/emqx/emqx-auth-mysql $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_auth_pgsql    = git-emqx https://github.com/emqx/emqx-auth-pgsql $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_auth_redis    = git-emqx https://github.com/emqx/emqx-auth-redis $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_auth_mongo    = git-emqx https://github.com/emqx/emqx-auth-mongo $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_auth_jwt      = git-emqx https://github.com/emqx/emqx-auth-jwt $(EMQX_DEPS_DEFAULT_VSN)

# mqtt-sn, coap and stomp
dep_emqx_sn    = git-emqx https://github.com/emqx/emqx-sn $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_coap  = git-emqx https://github.com/emqx/emqx-coap $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_lwm2m = git-emqx https://github.com/emqx/emqx-lwm2m $(EMQX_DEPS_DEFAULT_VSN)
dep_emqx_stomp = git-emqx https://github.com/emqx/emqx-stomp $(EMQX_DEPS_DEFAULT_VSN)

# plugin template
dep_emqx_plugin_template = git-emqx https://github.com/emqx/emq-plugin-template $(EMQX_DEPS_DEFAULT_VSN)

# web_hook
dep_emqx_web_hook  = git-emqx https://github.com/emqx/emqx-web-hook $(EMQX_DEPS_DEFAULT_VSN)

dep_emqx_lua_hook  = git-emqx https://github.com/emqx/emqx-lua-hook $(EMQX_DEPS_DEFAULT_VSN)

#tls psk
dep_emqx_psk_file = git-emqx https://github.com/emqx/emqx-psk-file $(EMQX_DEPS_DEFAULT_VSN)

#rule engine
dep_emqx_rule_engine = git-emqx https://github.com/emqx/emqx-rule-engine $(EMQX_DEPS_DEFAULT_VSN)

# Add this dependency before including erlang.mk
all:: OTP_21_OR_NEWER

$(shell [ -f erlang.mk ] || curl -s -o erlang.mk https://raw.githubusercontent.com/emqx/erlmk/win30/erlang.mk)
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
