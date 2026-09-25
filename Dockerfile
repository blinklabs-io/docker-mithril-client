FROM rust:slim-bookworm AS rustbuilder
# Can be a git tag or commit SHA
# 3f6cb73f491eb3195d02318643e40836fb093acc (0.13.20/2630.1-hotfix)
ARG MITHRIL_VERSION=3f6cb73f491eb3195d02318643e40836fb093acc
ENV MITHRIL_VERSION=${MITHRIL_VERSION}
RUN apt-get update && apt-get install -y --no-install-recommends git make gcc libc6-dev
WORKDIR /code
RUN echo "Building ${MITHRIL_VERSION}..." \
    && git clone --filter=blob:none https://github.com/input-output-hk/mithril.git \
    && cd mithril \
    && git checkout ${MITHRIL_VERSION} \
    && cargo build --release -p mithril-client-cli \
    && strip target/release/mithril-client

FROM ghcr.io/blinklabs-io/cardano-configs:20260915-1 AS cardano-configs

FROM debian:bookworm-slim AS mithril-client
COPY --from=rustbuilder /code/mithril/target/release/mithril-client /bin/
COPY --from=cardano-configs /config/ /opt/cardano/config/
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/bin/mithril-client"]
