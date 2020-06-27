ARG BUILD_FROM=emqx/build-env:erl22.3-ubuntu20.04
FROM ${BUILD_FROM}

ARG SYSTEM=ubuntu20.04
ARG EMQX_NAME=emqx
ARG EMQX_DEPS_DEFAULT_VSN=master

ENV REL_PATH="/emqx-rel"
ENV PACKAGE_PATH="/emqx-rel/_packages/${EMQX_NAME}"

COPY . /emqx-rel

WORKDIR /emqx-rel

RUN echo "========================= build ${EMQX_NAME} =========================" \
    && make ${EMQX_NAME} \
    && pkg=${EMQX_NAME}-${SYSTEM}-${EMQX_DEPS_DEFAULT_VSN#v}-$(uname -m).zip \
    && cd _build/${EMQX_NAME}/rel/ \
    && zip -rq $pkg emqx \
    && mkdir -p ${PACKAGE_PATH} \
    && mv $pkg ${PACKAGE_PATH} \
    && cd -

RUN make ${EMQX_NAME}-pkg

RUN /emqx-rel/.github/workflows/script/tests.sh