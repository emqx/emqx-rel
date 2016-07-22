PROJECT = emqttd-relx
PROJECT_DESCRIPTION = Release project for emqttd-2.0
PROJECT_VERSION = 2.0

DEPS = emqttd emqttd_dashboard emqttd_recon emqttd_reloader emqttd_stomp \
	   emqttd_auth_http emqttd_auth_mysql emqttd_auth_pgsql emqttd_auth_redis \
	   emqttd_auth_mongo emqttd_plugin_template

# emqttd
dep_emqttd 			 = git https://github.com/emqtt/emqttd gen_conf
dep_emqttd_dashboard = git https://github.com/emqtt/emqttd_dashboard gen_conf
dep_emqttd_recon     = git https://github.com/emqtt/emqttd_recon gen_conf
dep_emqttd_reloader  = git https://github.com/emqtt/emqttd_reloader gen_conf
dep_emqttd_stomp	 = git https://github.com/emqtt/emqttd_stomp gen_conf

# emqttd auth plugins
dep_emqttd_auth_http       = git https://github.com/emqtt/emqttd_auth_http gen_conf
dep_emqttd_auth_mysql      = git https://github.com/emqtt/emqttd_plugin_mysql gen_conf
dep_emqttd_auth_pgsql      = git https://github.com/emqtt/emqttd_plugin_pgsql gen_conf
dep_emqttd_auth_redis      = git https://github.com/emqtt/emqttd_plugin_redis gen_conf
dep_emqttd_auth_mongo      = git https://github.com/emqtt/emqttd_plugin_mongo gen_conf
dep_emqttd_plugin_template = git https://github.com/emqtt/emqttd_plugin_template gen_conf

COVER = true

include erlang.mk

plugins:
	@rm etc/plugins/*
	@for config in ./deps/*/etc/*.conf ; do cp $${config} etc/plugins/ ; done

app:: plugins


