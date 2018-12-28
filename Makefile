PROJECT = emqx-rel
PROJECT_DESCRIPTION = Release Project for EMQ X Broker

# All emqx app names. Repo name, not Erlang app name
# By default, app name is the same as repo name with dash replaced by underscore.
# Otherwise define the dependency in regular erlang.mk style:
## DEPS += emqx
## dep_emqx = git https://github.com/emqx/emqx.git emqx30

# Default release profiles
RELX_OUTPUT_DIR ?= _rel
REL_PROFILE ?= dev

# Deploy to edge or cloud
DEPLOY ?= cloud

MAIN_APPS = emqx emqx-retainer emqx-recon emqx-management \
            emqx-auth-clientid emqx-auth-username emqx-auth-http \
            emqx-auth-mysql emqx-reloader \
            emqx-sn emqx-coap emqx-stomp emqx-web-hook \
            emqx-auth-jwt emqx-delayed-publish

CLOUD_APPS = emqx-lwm2m emqx-dashboard emqx-auth-ldap emqx-auth-pgsql emqx-auth-redis emqx-auth-mongo emqx-plugin-template emqx-statsd emqx-lua-hook

ifeq (cloud,$(DEPLOY))
  MAIN_APPS += $(CLOUD_APPS)
endif

# Default version for all MAIN_APPS
## This is either a tag or branch name for ALL dependencies
EMQX_DEPS_DEFAULT_VSN ?= v3.0.0

dash = -
uscore = _

# Make Erlang app name from repo name.
# Replace dashes with underscores
app_name = $(subst $(dash),$(uscore),$(1))

# set emqx_app_name_vsn = x.y.z to override default version
app_vsn = $(if $($(call app_name,$(1))_vsn),$($(call app_name,$(1))_vsn),$(EMQX_DEPS_DEFAULT_VSN))

DEPS += $(foreach dep,$(MAIN_APPS),$(call app_name,$(dep)))

# Inject variables like
# dep_app_name = git-emqx https://github.com/emqx/app-name branch-or-tag
# for erlang.mk
$(foreach dep,$(MAIN_APPS),$(eval dep_$(call app_name,$(dep)) = git-emqx https://github.com/emqx/$(dep) $(call app_vsn,$(dep))))

# Add this dependency before including erlang.mk
all:: OTP_21_OR_NEWER

# COVER = true

$(shell [ -f erlang.mk ] || curl -s -o erlang.mk https://raw.githubusercontent.com/emqx/erlmk/master/erlang.mk)

include erlang.mk

# Fail fast in case older than OTP 21
.PHONY: OTP_21_OR_NEWER
OTP_21_OR_NEWER:
	@erl -noshell -eval "R = list_to_integer(erlang:system_info(otp_release)), halt(if R >= 21 -> 0; true -> 1 end)"

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

vm_args:
	@if [ $(DEPLOY) = "cloud" ] ; then \
		cp deps/emqx/etc/vm.args rel/conf/vm.args ; \
	else \
		cp deps/emqx/etc/vm.args.$(DEPLOY) rel/conf/vm.args ; \
	fi ;

relx_conf:
	@if [ $(DEPLOY) != "cloud" ] ; then \
		cp relx.config.$(DEPLOY) relx.config ; \
	fi ;

loaded_plugins:
	@if [ $(DEPLOY) != "cloud" ] ; then \
		cp data/loaded_plugins.$(DEPLOY) data/loaded_plugins ; \
	fi ;

app:: plugins vm_args relx_conf loaded_plugins vars-ln

vars-ln:
	ln -s -f vars-$(REL_PROFILE).config vars.config

