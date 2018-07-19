PROJECT = emqx-rel
PROJECT_DESCRIPTION = Release Project for EMQ X Broker
PROJECT_VERSION = 3.0

DEPS = goldrush gen_rpc
dep_goldrush = git https://github.com/basho/goldrush 0.1.9
dep_gen_rpc  = git https://github.com/emqx/gen_rpc 2.1.1

DEPS += emqx emqx_retainer emqx_recon emqx_reloader
# emqx and plugins
dep_emqx            = git https://github.com/emqtt/emqttd emqx30-dev
dep_emqx_retainer   = git https://github.com/emqx/emqx-retainer emqx30
dep_emqx_recon      = git https://github.com/emqx/emqx-recon emqx30
dep_emqx_reloader   = git https://github.com/emqx/emqx-reloader emqx30

BUILD_DEPS = cuttlefish
dep_cuttlefish = git https://github.com/emqx/cuttlefish

NO_AUTOPATCH = cuttlefish gen_rpc

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
