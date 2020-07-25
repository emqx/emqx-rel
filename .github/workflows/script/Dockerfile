ARG BUILD_FROM=emqx/build-env:erl22.3-ubuntu20.04
FROM ${BUILD_FROM}

ARG SYSTEM=ubuntu20.04
ARG EMQX_NAME=emqx
ARG EMQX_DEPS_DEFAULT_VSN=master

COPY . /emqx-rel

WORKDIR /emqx-rel

# RUN echo "========================= build ${EMQX_NAME} =========================" \
#     && make ${EMQX_NAME} \
#     && pkg=${EMQX_NAME}-${SYSTEM}-${EMQX_DEPS_DEFAULT_VSN#v}-$(uname -m).zip \
#     && cd _build/${EMQX_NAME}/rel/ \
#     && zip -rq $pkg emqx \
#     && mkdir -p /emqx-rel/_packages/${EMQX_NAME} \
#     && mv $pkg /emqx-rel/_packages/${EMQX_NAME} \
#     && cd -

RUN make ${EMQX_NAME}-pkg

RUN /emqx-rel/.github/workflows/script/tests.sh
