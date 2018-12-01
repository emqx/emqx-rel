PROJECT = emqx-rel
PROJECT_DESCRIPTION = Release Project for EMQ X Broker

# All emqx app names. Repo name, not Erlang app name
# By default, app name is the same as repo name with dash replaced by underscore.
# Otherwise define the dependency in regular erlang.mk style:
# DEPS += special_app
# dep_special_app = git https//github.com/emqx/some-name.git branch-or-tag
DEPS += emqx
dep_emqx = git https://github.com/emqx/emqx win30
OUR_APPS = emqx-retainer emqx-recon emqx-reloader emqx-dashboard emqx-management \
           emqx-auth-clientid emqx-auth-username emqx-auth-ldap emqx-auth-http \
           emqx-auth-mysql emqx-auth-pgsql emqx-auth-redis emqx-auth-mongo \
           emqx-sn emqx-coap emqx-lwm2m emqx-stomp emqx-plugin-template emqx-web-hook \
           emqx-auth-jwt emqx-statsd emqx-delayed-publish emqx-lua-hook

# Default release profiles
RELX_OUTPUT_DIR ?= _rel
REL_PROFILE ?= dev

# Default version for all OUR_APPS
## This is either a tag or branch name for ALL dependencies
EMQX_DEPS_DEFAULT_VSN ?= v3.0-rc.5

dash = -
uscore = _

# Make Erlang app name from repo name.
# Replace dashes with underscores
app_name = $(subst $(dash),$(uscore),$(1))

# set emqx_app_name_vsn = x.y.z to override default version
app_vsn = $(if $($(call app_name,$(1))_vsn),$($(call app_name,$(1))_vsn),$(EMQX_DEPS_DEFAULT_VSN))

DEPS += $(foreach dep,$(OUR_APPS),$(call app_name,$(dep)))

# Inject variables like
# dep_app_name = git-emqx https://github.com/emqx/app-name branch-or-tag
# for erlang.mk
$(foreach dep,$(OUR_APPS),$(eval dep_$(call app_name,$(dep)) = git-emqx https://github.com/emqx/$(dep) $(call app_vsn,$(dep))))

GIT_VSN = $(shell git --version | grep -oE "[0-9]{1,2}\.[0-9]{1,2}")
GIT_VSN_17_COMP = $(shell echo -e "$(GIT_VSN)\n1.7" | sort -V | tail -1)
ifeq ($(GIT_VSN_17_COMP),1.7)
	MAYBE_SHALLOW =
else
	MAYBE_SHALLOW = -c advice.detachedHead=false --depth 1
endif

# Override default git full-clone with depth=1 shallow-clone
ifeq ($(GIT_VSN_17_COMP),1.7)
define dep_fetch_git-emqx
	git clone -q -n -- $(call dep_repo,$(1)) $(DEPS_DIR)/$(call dep_name,$(1)); \
		cd $(DEPS_DIR)/$(call dep_name,$(1)) && git checkout -q $(call dep_commit,$(1))
endef
else
define dep_fetch_git-emqx
	git clone -q -c advice.detachedHead=false --depth 1 -b $(call dep_commit,$(1)) -- $(call dep_repo,$(1)) $(DEPS_DIR)/$(call dep_name,$(1))
endef
endif

# Add this dependency before including erlang.mk
all:: OTP_21_OR_NEWER

# COVER = true
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

app:: plugins vars-ln

vars-ln:
	ln -s -f vars-$(REL_PROFILE).config vars.config

