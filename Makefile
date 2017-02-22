PROJECT = emq-relx
PROJECT_DESCRIPTION = Release Project for the EMQ Broker
PROJECT_VERSION = 2.1.0

DEPS = emqttd emq_modules emq_dashboard emq_retainer emq_recon emq_reloader \
	   emq_auth_clientid emq_auth_username emq_auth_ldap emq_auth_http \
	   emq_auth_mysql emq_auth_pgsql emq_auth_redis emq_auth_mongo \
	   emq_sn emq_coap emq_stomp emq_plugin_template \

# emq deps
dep_emqttd        = git https://github.com/emqtt/emqttd emq20
dep_emq_modules   = git https://github.com/emqtt/emq-modules emq20
dep_emq_dashboard = git https://github.com/emqtt/emq-dashboard emq20
dep_emq_retainer  = git https://github.com/emqtt/emq-retainer emq20
dep_emq_recon     = git https://github.com/emqtt/emq-recon emq20
dep_emq_reloader  = git https://github.com/emqtt/emq-reloader emq20

# emq auth/acl plugins
dep_emq_auth_clientid   = git https://github.com/emqtt/emq-auth-clientid emq20
dep_emq_auth_username   = git https://github.com/emqtt/emq-auth-username emq20
dep_emq_auth_ldap       = git https://github.com/emqtt/emq-auth-ldap emq20
dep_emq_auth_http       = git https://github.com/emqtt/emq-auth-http emq20
dep_emq_auth_mysql      = git https://github.com/emqtt/emq-auth-mysql emq20
dep_emq_auth_pgsql      = git https://github.com/emqtt/emq-auth-pgsql emq20
dep_emq_auth_redis      = git https://github.com/emqtt/emq-auth-redis emq20
dep_emq_auth_mongo      = git https://github.com/emqtt/emq-auth-mongo emq20

# mqtt-sn, coap and stomp
dep_emq_sn 	  = git https://github.com/emqtt/emq-sn emq20
dep_emq_coap  = git https://github.com/emqtt/emq-coap emq20
dep_emq_stomp = git https://github.com/emqtt/emq-stomp emq20

# plugin template
dep_emq_plugin_template = git https://github.com/emqtt/emq-plugin-template emq20

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

