FROM rust:bookworm AS rustbuilder
ARG MITHRIL_VERSION=2408.0
ENV MITHRIL_VERSION=${MITHRIL_VERSION}
WORKDIR /code
RUN echo "Building tags/${MITHRIL_VERSION}..." \
    && git clone https://github.com/input-output-hk/mithril.git --depth 1 -b ${MITHRIL_VERSION} \
    && cd mithril \
    && git checkout tags/${MITHRIL_VERSION} \
    && cargo build --release -p mithril-client-cli

FROM debian:bookworm-slim as mithril-client
COPY --from=rustbuilder /code/mithril/target/release/mithril-client /bin/
RUN apt-get update -y \
    && apt-get install -y \
       ca-certificates \
       libssl3 \
       llvm-14-runtime \
       sqlite3 \
       wget \
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/bin/mithril-client"]
