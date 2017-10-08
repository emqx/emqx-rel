PROJECT = emqx-rel
PROJECT_DESCRIPTION = Release Project for EMQ X Broker
PROJECT_VERSION = 2.4

NO_AUTOPATCH = gen_rpc cuttlefish emqx_elixir_plugin
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
dep_emqx            = git https://github.com/emqtt/emqttd X

dep_emqx_modules    = git https://github.com/emqtt/emq-modules X
dep_emqx_management = git https://github.com/emqtt/emq-management X
dep_emqx_dashboard  = git https://github.com/emqtt/emq-dashboard X
dep_emqx_retainer   = git https://github.com/emqtt/emq-retainer X
dep_emqx_recon      = git https://github.com/emqtt/emq-recon X
dep_emqx_reloader   = git https://github.com/emqtt/emq-reloader X
dep_emqx_statsd     = git https://github.com/emqtt/emqx-statsd X
dep_emqx_delayed_publish = git https://github.com/emqtt/emqx-delayed-publish X
# emqx auth/acl plugins
dep_emqx_auth_clientid = git https://github.com/emqtt/emq-auth-clientid X
dep_emqx_auth_username = git https://github.com/emqtt/emq-auth-username X
dep_emqx_auth_ldap     = git https://github.com/emqtt/emq-auth-ldap X
dep_emqx_auth_http     = git https://github.com/emqtt/emq-auth-http X
dep_emqx_auth_mysql    = git https://github.com/emqtt/emq-auth-mysql X
dep_emqx_auth_pgsql    = git https://github.com/emqtt/emq-auth-pgsql X
dep_emqx_auth_redis    = git https://github.com/emqtt/emq-auth-redis X
dep_emqx_auth_mongo    = git https://github.com/emqtt/emq-auth-mongo X
dep_emqx_auth_jwt      = git https://github.com/emqtt/emq-auth-jwt X

# emqx mqtt-sn, coap and stomp
dep_emqx_sn    = git https://github.com/emqtt/emq-sn X
dep_emqx_coap  = git https://github.com/emqtt/emq-coap X
dep_emqx_stomp = git https://github.com/emqtt/emq-stomp X
dep_emqx_lwm2m = git https://github.com/emqtt/emq-lwm2m X

# emqx plugin template
dep_emqx_plugin_template = git https://github.com/emqtt/emq-plugin-template X

# web_hook lua_hook
dep_emqx_web_hook  = git https://github.com/emqtt/emq-web-hook X
dep_emqx_lua_hook  = git https://github.com/emqtt/emq-lua-hook X
#dep_emqx_elixir_plugin = git  https://github.com/emqtt/emq-elixir-plugin X

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
