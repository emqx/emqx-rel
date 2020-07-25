export

ifneq ($(shell uname -s),Linux)
	$(shell echo "Please execute this script under Linux")
	exit
endif
# The version-release used for package
ifneq ($(shell echo $(EMQX_DEPS_DEFAULT_VSN) | grep -oE "^[ev0-9]+\.[0-9]+(\.[0-9]+)?"),)
	PKG_VSN := $(patsubst v%,%,$(patsubst e%,%,$(EMQX_DEPS_DEFAULT_VSN)))
else
	PKG_VSN := $(patsubst v%,%,$(patsubst e%,%,$(shell git describe --abbrev=0 --tags)))
endif

# Default name
EMQX_BUILD ?= emqx-pkg
ifneq ($(shell echo $(EMQX_BUILD) |grep edge),)
	EMQX_NAME := emqx-edge
else
	EMQX_NAME := emqx
endif

ifneq ($(shell cat /etc/*-release |grep -o -i centos),)
	ID := centos
	VERSION_ID := $(shell rpm --eval '%{centos_ver}')
else
	ID := $(shell sed -n '/^ID=/p' /etc/os-release | sed -r 's/ID=(.*)/\1/g' | sed 's/"//g' )
	VERSION_ID := $(shell sed -n '/^VERSION_ID=/p' /etc/os-release | sed -r 's/VERSION_ID=(.*)/\1/g' | sed 's/"//g')
endif
SYSTEM := $(shell echo $(ID)$(VERSION_ID) | sed -r "s/([a-zA-Z]*)-.*/\1/g")
##
## Support RPM and Debian based linux systems
##
ifeq ($(ID),ubuntu)
	PKGERDIR := deb
else ifeq ($(ID),debian)
	PKGERDIR := deb
else ifeq ($(ID),raspbian)
	PKGERDIR := deb
else
	PKGERDIR := rpm
endif

UNDIR := /tmp/emqx_untar
PKG_DIR:= $(EMQX_REL)/_packages/$(EMQX_NAME)
TAR_PKG := $(EMQX_REL)/_build/$(EMQX_NAME)/rel/emqx/emqx-$(PKG_VSN).tar.gz
ZIP_PKG := $(PKG_DIR)/$(EMQX_NAME)-$(SYSTEM)-$(PKG_VSN)-$(shell uname -m).zip

.PHONY: all
all: clean zip
	$(if $(PKGERDIR),,$(error "Operating system '$(OS)' not supported"))
	cd $(PKGERDIR) && $(MAKE)

clean:
	rm -rf $(UNDIR)
	rm -rf package
	make -C rpm clean
	make -C deb clean

.PHONY: zip
zip:
	mkdir -p $(PKG_DIR)
	mkdir -p $(UNDIR)/emqx
	tar zxf $(TAR_PKG) -C $(UNDIR)/emqx
	cd $(UNDIR) && zip -q -r $(ZIP_PKG) ./emqx && cd -

.PHONY: deb
deb:
	make -C deb

.PHONY: rpm
rpm:
	make -C rpm

