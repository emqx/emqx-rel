PROJECT = emq-relx
PROJECT_DESCRIPTION = Release Project for the EMQ Broker
PROJECT_VERSION = 2.0.7

DEPS = emqttd emq_dashboard emq_recon emq_reloader emq_stomp emq_plugin_template \
	   emq_mod_rewrite emq_mod_presence emq_mod_retainer emq_mod_subscription \
	   emq_auth_clientid emq_auth_username emq_auth_ldap emq_auth_http \
	   emq_auth_mysql emq_auth_pgsql emq_auth_redis emq_auth_mongo \
	   emq_sn emq_coap

# emq deps
dep_emqttd        = git https://github.com/emqtt/emqttd v2.0.7
dep_emq_dashboard = git https://github.com/emqtt/emq-dashboard v2.0.7
dep_emq_recon     = git https://github.com/emqtt/emq-recon v2.0.7
dep_emq_reloader  = git https://github.com/emqtt/emq-reloader v2.0.7
dep_emq_stomp     = git https://github.com/emqtt/emq-stomp v2.0.7

# emq modules
dep_emq_mod_presence     = git https://github.com/emqtt/emq-mod-presence v2.0.7
dep_emq_mod_retainer     = git https://github.com/emqtt/emq-mod-retainer v2.0.7
dep_emq_mod_rewrite      = git https://github.com/emqtt/emq-mod-rewrite v2.0.7
dep_emq_mod_subscription = git https://github.com/emqtt/emq-mod-subscription v2.0.7

# emq auth/acl plugins
dep_emq_auth_clientid   = git https://github.com/emqtt/emq-auth-clientid v2.0.7
dep_emq_auth_username   = git https://github.com/emqtt/emq-auth-username v2.0.7
dep_emq_auth_ldap       = git https://github.com/emqtt/emq-auth-ldap v2.0.7
dep_emq_auth_http       = git https://github.com/emqtt/emq-auth-http v2.0.7
dep_emq_auth_mysql      = git https://github.com/emqtt/emq-auth-mysql v2.0.7
dep_emq_auth_pgsql      = git https://github.com/emqtt/emq-auth-pgsql v2.0.7
dep_emq_auth_redis      = git https://github.com/emqtt/emq-auth-redis v2.0.7
dep_emq_auth_mongo      = git https://github.com/emqtt/emq-auth-mongo v2.0.7
dep_emq_plugin_template = git https://github.com/emqtt/emq-plugin-template v2.0.7

# mqtt-sn and coap
dep_emq_sn 	= git https://github.com/emqtt/emq-sn v0.2.7
dep_emq_coap = git https://github.com/emqtt/emq-coap v0.2.7

# COVER = true

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

