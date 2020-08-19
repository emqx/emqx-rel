ARG BUILD_FROM=emqx/build-env:erl22.3-ubuntu20.04
FROM ${BUILD_FROM}

ARG EMQX_NAME=emqx

COPY . /emqx-rel

WORKDIR /emqx-rel

RUN make ${EMQX_NAME}-pkg

RUN /emqx-rel/.ci/build_packages/tests.sh
