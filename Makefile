PROJECT = emqttd-relx
PROJECT_DESCRIPTION = Release project for EMQ 2.0
PROJECT_VERSION = 2.0

DEPS = emqttd emqttd_dashboard emqttd_recon emqttd_reloader emqttd_stomp emqttd_auth_ldap \
	   emqttd_auth_http emqttd_auth_mysql emqttd_auth_pgsql emqttd_auth_redis \
	   emqttd_auth_mongo emqttd_plugin_template emqttd_sn emqttd_coap

# emqttd
dep_emqttd 			 = git https://github.com/emqtt/emqttd master
dep_emqttd_dashboard = git https://github.com/emqtt/emqttd_dashboard master
dep_emqttd_recon     = git https://github.com/emqtt/emqttd_recon master
dep_emqttd_reloader  = git https://github.com/emqtt/emqttd_reloader master
dep_emqttd_stomp	 = git https://github.com/emqtt/emqttd_stomp master

# emqttd auth plugins
dep_emqttd_auth_ldap       = git https://github.com/emqtt/emqttd_auth_ldap master
dep_emqttd_auth_http       = git https://github.com/emqtt/emqttd_auth_http master
dep_emqttd_auth_mysql      = git https://github.com/emqtt/emqttd_auth_mysql master
dep_emqttd_auth_pgsql      = git https://github.com/emqtt/emqttd_auth_pgsql master
dep_emqttd_auth_redis      = git https://github.com/emqtt/emqttd_auth_redis master
dep_emqttd_auth_mongo      = git https://github.com/emqtt/emqttd_auth_mongo master
dep_emqttd_plugin_template = git https://github.com/emqtt/emqttd_plugin_template master

# mqtt-sn and coap
dep_emqttd_sn 	= git https://github.com/emqtt/emqttd_sn master
dep_emqttd_coap = git https://github.com/emqtt/emqttd_coap master

# COVER = true

include erlang.mk

plugins:
	@for config in ./deps/*/etc/*.conf ; do cp $${config} etc/plugins/ ; done

app:: plugins

