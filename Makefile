PROJECT = emq-relx
PROJECT_DESCRIPTION = Release Project for the EMQ Broker
PROJECT_VERSION = 2.3.1

## Fix 'rebar command not found'
DEPS = goldrush
dep_goldrush = git https://github.com/basho/goldrush 0.1.9

DEPS += emqttd emq_modules emq_dashboard emq_retainer emq_recon emq_reloader \
        emq_auth_clientid emq_auth_username emq_auth_ldap emq_auth_http \
        emq_auth_mysql emq_auth_pgsql emq_auth_redis emq_auth_mongo \
        emq_sn emq_coap emq_stomp emq_plugin_template emq_web_hook \
        emq_lua_hook emq_auth_jwt

# emq deps
dep_emqttd        = git https://github.com/emqtt/emqttd emq24
dep_emq_modules   = git https://github.com/emqtt/emq-modules emq24
dep_emq_dashboard = git https://github.com/emqtt/emq-dashboard emq24
dep_emq_retainer  = git https://github.com/emqtt/emq-retainer emq24
dep_emq_recon     = git https://github.com/emqtt/emq-recon emq24
dep_emq_reloader  = git https://github.com/emqtt/emq-reloader emq24

# emq auth/acl plugins
dep_emq_auth_clientid = git https://github.com/emqtt/emq-auth-clientid emq24
dep_emq_auth_username = git https://github.com/emqtt/emq-auth-username emq24
dep_emq_auth_ldap     = git https://github.com/emqtt/emq-auth-ldap emq24
dep_emq_auth_http     = git https://github.com/emqtt/emq-auth-http emq24
dep_emq_auth_mysql    = git https://github.com/emqtt/emq-auth-mysql emq24
dep_emq_auth_pgsql    = git https://github.com/emqtt/emq-auth-pgsql emq24
dep_emq_auth_redis    = git https://github.com/emqtt/emq-auth-redis emq24
dep_emq_auth_mongo    = git https://github.com/emqtt/emq-auth-mongo emq24
dep_emq_auth_jwt      = git https://github.com/emqtt/emq-auth-jwt emq24

# mqtt-sn, coap and stomp
dep_emq_sn    = git https://github.com/emqtt/emq-sn emq24
dep_emq_coap  = git https://github.com/emqtt/emq-coap emq24
dep_emq_stomp = git https://github.com/emqtt/emq-stomp emq24

# plugin template
dep_emq_plugin_template = git https://github.com/emqtt/emq-plugin-template emq24

# web_hook lua_hook
dep_emq_web_hook  = git https://github.com/emqtt/emq-web-hook emq24
dep_emq_lua_hook  = git https://github.com/emqtt/emq-lua-hook emq24
#dep_emq_elixir_plugin = git  https://github.com/emqtt/emq-elixir-plugin emq24

# COVER = true

#NO_AUTOPATCH = emq_elixir_plugin

include erlang.mk

plugins:
	@rm -rf rel
	@mkdir -p rel/conf/plugins/ rel/schema/
	@for conf in $(DEPS_DIR)/*/etc/*.conf* ; do \
		if [ "emq.conf" = "$${conf##*/}" ] ; then \
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
