.PHONY: deps-all
deps-all: $(REBAR) $(PROFILES:%=deps-%) $(PKG_PROFILES:%=deps-%)

.PHONY: $(PROFILES:%=deps-%) $(PKG_PROFILES:%=deps-%)
$(PROFILES:%=deps-%) $(PKG_PROFILES:%=deps-%): $(REBAR)
ifneq ($(shell echo $(@:deps-%=%) |grep edge),)
	export EMQX_DESC="EMQ X Edge"
else
	export EMQX_DESC="EMQ X Broker"
endif
	$(REBAR) as $(@:deps-%=%) get-deps

.PHONY: $(PROFILES:%=relup-%)
$(PROFILES:%=relup-%): $(REBAR)
ifneq ($(OS),Windows_NT)
	$(REBAR) as $(@:relup-%=%) relup
endif

.PHONY: $(PROFILES:%=%-tar) $(PKG_PROFILES:%=%-tar)
$(PROFILES:%=%-tar) $(PKG_PROFILES:%=%-tar): $(REBAR)
ifneq ($(OS),Windows_NT)
	@ln -snf _build/$(subst -tar,,$(@))/lib ./_checkouts
endif
ifneq ($(shell echo $(@) |grep edge),)
	export EMQX_DESC="EMQ X Edge"
else
	export EMQX_DESC="EMQ X Broker"
endif
	$(REBAR) as $(subst -tar,,$(@)) tar

# Build packages
.PHONY: $(PKG_PROFILES)
$(PKG_PROFILES:%=%): $(REBAR)
ifneq ($(shell echo $(@) |grep edge),)
	export EMQX_DESC="EMQ X Edge"
else
	export EMQX_DESC="EMQ X Broker"
endif
ifeq ($(shell uname -s),Linux)
	make $(subst -pkg,,$(@))-tar
	make $(@)-tar
	EMQX_REL=$$(pwd) EMQX_BUILD=$(@) make -C deploy/packages
endif
ifeq ($(shell uname -s),Darwin)
	make $(subst -pkg,,$(@))-tar
	make $(@)-macos
endif

.PHONY: $(PKG_PROFILES:%=%-macos)
$(PKG_PROFILES:%=%-macos):
	tard="/tmp/emqx_untar_$(PKG_VSN)";\
	rm -rf "$${tard}" && mkdir -p "$${tard}/emqx";\
	prof="$(subst -pkg-macos,,$(@))";\
	relpath="$$(pwd)/_build/$${prof}/rel/emqx";\
	pkgpath="$$(pwd)/_packages/$${prof}"; \
	mkdir -p $${pkgpath}; \
	tarball="$${relpath}/emqx-$(PKG_VSN).tar.gz";\
	zipball="$${pkgpath}/emqx-macos-$(PKG_VSN).zip";\
	tar zxf "$${tarball}" -C "$${tard}/emqx"; \
	pushd "$${tard}"; \
	zip -q -r "$${zipball}" ./emqx; \
	popd

# Build docker image
.PHONY: $(PROFILES:%=%-docker-build)
$(PROFILES:%=%-docker-build): $(PROFILES:%=deps-%)
ifneq ($(shell echo $(@) |grep edge),)
	TARGET=emqx/emqx-edge make -C deploy/docker
else
	TARGET=emqx/emqx make -C deploy/docker
endif

# Save docker images
.PHONY: $(PROFILES:%=%-docker-save)
$(PROFILES:%=%-docker-save):
ifneq ($(shell echo $(@) |grep edge),)
	TARGET=emqx/emqx-edge make -C deploy/docker save
else
	TARGET=emqx/emqx make -C deploy/docker save
endif

# Push docker image
.PHONY: $(PROFILES:%=%-docker-push)
$(PROFILES:%=%-docker-push):
ifneq ($(shell echo $(@) |grep edge),)
	TARGET=emqx/emqx-edge make -C deploy/docker push
	TARGET=emqx/emqx-edge make -C deploy/docker manifest_list
else
	TARGET=emqx/emqx make -C deploy/docker push
	TARGET=emqx/emqx make -C deploy/docker manifest_list
endif

# Clean docker image
.PHONY: $(PROFILES:%=%-docker-clean)
$(PROFILES:%=%-docker-clean):
ifneq ($(shell echo $(@) |grep edge),)
	TARGET=emqx/emqx-edge make -C deploy/docker clean
else
	TARGET=emqx/emqx make -C deploy/docker clean
endif

