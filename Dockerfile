FROM rust:slim-bookworm AS rustbuilder
# Can be a git tag or commit SHA
# 0f6d54dd9c229104d0bfcca670d320266899f0ca (0.13.19)
ARG MITHRIL_VERSION=0f6d54dd9c229104d0bfcca670d320266899f0ca
ENV MITHRIL_VERSION=${MITHRIL_VERSION}
RUN apt-get update && apt-get install -y --no-install-recommends git make gcc libc6-dev
WORKDIR /code
RUN echo "Building ${MITHRIL_VERSION}..." \
    && git clone --filter=blob:none https://github.com/input-output-hk/mithril.git \
    && cd mithril \
    && git checkout ${MITHRIL_VERSION} \
    && cargo build --release -p mithril-client-cli \
    && strip target/release/mithril-client

FROM ghcr.io/blinklabs-io/cardano-configs:20260707-2 AS cardano-configs

FROM debian:bookworm-slim AS mithril-client
COPY --from=rustbuilder /code/mithril/target/release/mithril-client /bin/
COPY --from=cardano-configs /config/ /opt/cardano/config/
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/bin/mithril-client"]
