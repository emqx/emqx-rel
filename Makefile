PROJECT = emqx-rel
PROJECT_DESCRIPTION = Release Project for EMQ X Broker
PROJECT_VERSION = 2.4

NO_AUTOPATCH = cuttlefish emqx_elixir_plugin
## Fix 'rebar command not found'
DEPS = goldrush
dep_goldrush = git https://github.com/basho/goldrush 0.1.9

DEPS += emqx emqx_modules emqx_management emqx_dashboard emqx_retainer \
        emqx_auth_clientid emqx_auth_username emqx_auth_ldap emqx_auth_http \
        emqx_auth_mysql emqx_auth_pgsql emqx_auth_redis emqx_auth_mongo \
		emqx_auth_jwt emqx_statsd emqx_delayed_publish emqx_recon emqx_reloader \
		emqx_web_hook emqx_lua_hook emqx_sn emqx_coap emqx_stomp emqx_lwm2m \
		emqx_plugin_template

# emqx modules
dep_emqx            = git git@github.com:emqx/emqx-enterprise

dep_emqx_modules    = git https://github.com/emqtt/emq-modules enterprise
dep_emqx_management = git https://github.com/emqx/emqx-management enterprise
dep_emqx_dashboard  = git https://github.com/emqtt/emq-dashboard enterprise
dep_emqx_retainer   = git https://github.com/emqtt/emq-retainer enterprise
dep_emqx_recon      = git https://github.com/emqtt/emq-recon enterprise
dep_emqx_reloader   = git https://github.com/emqtt/emq-reloader enterprise
dep_emqx_statsd     = git https://github.com/emqx/emqx-statsd enterprise
dep_emqx_delayed_publish = git https://github.com/emqx/emqx-delayed-publish enterprise
# emqx auth/acl plugins
dep_emqx_auth_clientid = git https://github.com/emqtt/emq-auth-clientid enterprise
dep_emqx_auth_username = git https://github.com/emqtt/emq-auth-username enterprise
dep_emqx_auth_ldap     = git https://github.com/emqtt/emq-auth-ldap enterprise
dep_emqx_auth_http     = git https://github.com/emqtt/emq-auth-http enterprise
dep_emqx_auth_mysql    = git https://github.com/emqtt/emq-auth-mysql enterprise
dep_emqx_auth_pgsql    = git https://github.com/emqtt/emq-auth-pgsql enterprise
dep_emqx_auth_redis    = git https://github.com/emqtt/emq-auth-redis enterprise
dep_emqx_auth_mongo    = git https://github.com/emqtt/emq-auth-mongo enterprise
dep_emqx_auth_jwt      = git https://github.com/emqtt/emq-auth-jwt enterprise

# emqx mqtt-sn, coap and stomp
dep_emqx_sn    = git https://github.com/emqtt/emq-sn enterprise
dep_emqx_coap  = git https://github.com/emqtt/emq-coap enterprise
dep_emqx_stomp = git https://github.com/emqtt/emq-stomp enterprise
dep_emqx_lwm2m = git https://github.com/emqx/emqx-lwm2m enterprise

# emqx plugin template
dep_emqx_plugin_template = git https://github.com/emqtt/emq-plugin-template enterprise

# web_hook lua_hook
dep_emqx_web_hook  = git https://github.com/emqtt/emq-web-hook enterprise
dep_emqx_lua_hook  = git https://github.com/emqtt/emq-lua-hook enterprise
#dep_emqx_elixir_plugin = git  https://github.com/emqtt/emq-elixir-plugin enterprise

BUILD_DEPS = cuttlefish
dep_cuttlefish = git https://github.com/emqtt/cuttlefish

# COVER = true

include erlang.mk

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
		else \
			cp $${conf} rel/conf/plugins ; \
		fi ; \
	done
	@for schema in $(DEPS_DIR)/*/priv/*.schema ; do \
		cp $${schema} rel/schema/ ; \
	done

app:: plugins
