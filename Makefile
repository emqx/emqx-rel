PROJECT = emqttd-relx
PROJECT_DESCRIPTION = Release project for EMQ 3.0
PROJECT_VERSION = 3.0

DEPS = emqttd emq_dashboard emq_recon emq_reloader emq_stomp emq_mod_rewrite \
	   emq_auth_ldap emq_auth_http emq_auth_mysql emq_auth_pgsql emq_auth_redis \
	   emq_auth_mongo emq_plugin_template emq_sn emq_coap cuttlefish

# emq deps
dep_emqttd        = git https://github.com/emqtt/emqttd emq30
dep_emq_dashboard = git https://github.com/emqtt/emqttd_dashboard emq30
dep_emq_recon     = git https://github.com/emqtt/emqttd_recon emq30
dep_emq_reloader  = git https://github.com/emqtt/emqttd_reloader emq30
dep_emq_stomp     = git https://github.com/emqtt/emqttd_stomp emq30

# emq modules
dep_emq_mod_rewrite  = git https://github.com/emqtt/emq_mod_rewrite emq30

# emq auth plugins
dep_emq_auth_ldap       = git https://github.com/emqtt/emqttd_auth_ldap emq30
dep_emq_auth_http       = git https://github.com/emqtt/emqttd_auth_http emq30
dep_emq_auth_mysql      = git https://github.com/emqtt/emqttd_auth_mysql emq30
dep_emq_auth_pgsql      = git https://github.com/emqtt/emqttd_auth_pgsql emq30
dep_emq_auth_redis      = git https://github.com/emqtt/emqttd_auth_redis emq30
dep_emq_auth_mongo      = git https://github.com/emqtt/emqttd_auth_mongo emq30
dep_emq_plugin_template = git https://github.com/emqtt/emqttd_plugin_template emq30

# mqtt-sn and coap
dep_emq_sn 	= git https://github.com/emqtt/emqttd_sn emq30
dep_emq_coap = git https://github.com/emqtt/emqttd_coap emq30

# cuttlefish
dep_cuttlefish = git https://github.com/basho/cuttlefish master

# COVER = true

include erlang.mk

plugins:
	@rm -rf rel
	@mkdir -p rel/conf/plugins/ rel/schema/
	@for conf in $(DEPS_DIR)/*/etc/*.conf* ; do \
		if [ "emq.conf" = "$${conf##*/}" ] ; then \
			cp $${conf} rel/conf/ ; \
		else \
			cp $${conf} rel/conf/plugins ; \
		fi ; \
	done
	@for schema in $(DEPS_DIR)/*/priv/*.schema ; do \
		cp $${schema} rel/schema/ ; \
	done

app:: plugins

