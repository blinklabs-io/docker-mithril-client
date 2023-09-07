FROM rust:bookworm AS rustbuilder
ARG MITHRIL_VERSION=2335.0
ENV MITHRIL_VERSION=${MITHRIL_VERSION}
WORKDIR /code
RUN echo "Building tags/${MITHRIL_VERSION}..." \
    && git clone https://github.com/input-output-hk/mithril.git \
    && cd mithril \
    && git fetch --all --recurse-submodules --tags \
    && git tag \
    && git checkout tags/${MITHRIL_VERSION} \
    && cargo build --release -p mithril-client

FROM debian:bookworm-slim as mithrill-client
COPY --from=rustbuilder /code/mithril/target/release/mithril-client /usr/local/bin/
RUN apt-get update -y \
    && apt-get install -y \
       ca-certificates \
       libssl3 \
       llvm-14-runtime \
       sqlite3 \
       wget \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/usr/local/bin/mithril-client"]
