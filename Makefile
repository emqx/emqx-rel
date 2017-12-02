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
dep_emqttd        = git https://github.com/emqtt/emqttd develop
dep_emq_modules   = git https://github.com/emqtt/emq-modules develop
dep_emq_dashboard = git https://github.com/emqtt/emq-dashboard develop
dep_emq_retainer  = git https://github.com/emqtt/emq-retainer develop
dep_emq_recon     = git https://github.com/emqtt/emq-recon develop
dep_emq_reloader  = git https://github.com/emqtt/emq-reloader develop

# emq auth/acl plugins
dep_emq_auth_clientid = git https://github.com/emqtt/emq-auth-clientid develop
dep_emq_auth_username = git https://github.com/emqtt/emq-auth-username develop
dep_emq_auth_ldap     = git https://github.com/emqtt/emq-auth-ldap develop
dep_emq_auth_http     = git https://github.com/emqtt/emq-auth-http develop
dep_emq_auth_mysql    = git https://github.com/emqtt/emq-auth-mysql develop
dep_emq_auth_pgsql    = git https://github.com/emqtt/emq-auth-pgsql develop
dep_emq_auth_redis    = git https://github.com/emqtt/emq-auth-redis develop
dep_emq_auth_mongo    = git https://github.com/emqtt/emq-auth-mongo develop
dep_emq_auth_jwt      = git https://github.com/emqtt/emq-auth-jwt develop

# mqtt-sn, coap and stomp
dep_emq_sn    = git https://github.com/emqtt/emq-sn develop
dep_emq_coap  = git https://github.com/emqtt/emq-coap develop
dep_emq_stomp = git https://github.com/emqtt/emq-stomp develop

# plugin template
dep_emq_plugin_template = git https://github.com/emqtt/emq-plugin-template develop

# web_hook lua_hook
dep_emq_web_hook  = git https://github.com/emqtt/emq-web-hook develop
dep_emq_lua_hook  = git https://github.com/emqtt/emq-lua-hook develop
#dep_emq_elixir_plugin = git  https://github.com/emqtt/emq-elixir-plugin develop

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
