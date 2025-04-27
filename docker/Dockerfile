FROM --platform=$BUILDPLATFORM crystallang/crystal:1.14 AS cross_compile_crystal

ARG TARGETARCH

USER root
WORKDIR /khodo

RUN apt-get update -q \
  && apt-get install --no-install-recommends -y \
    git \
    libsqlite3-dev \
    libc6-dev \
    libevent-dev \
    libgmp-dev \
    libpcre2-dev \
    libpng-dev \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev

WORKDIR /khodo
COPY ./shard.yml /khodo/
COPY ./shard.lock /khodo/

RUN shards install --without-development

COPY ./ /khodo
RUN mkdir /khodo/build

# Parallelise slow Crystal builds
FROM cross_compile_crystal AS server_build

RUN crystal build --static --release --cross-compile --target ${TARGETARCH}-unknown-linux-gnu src/start_server.cr -o build/start_server.o

FROM cross_compile_crystal AS tasks_build

RUN crystal build --static --release --cross-compile --target ${TARGETARCH}-unknown-linux-gnu tasks.cr -o build/tasks.o

FROM debian:bookworm-slim AS crystal_link

RUN apt-get update -q \
  && apt-get install --no-install-recommends -y \
    build-essential \
    libgc-dev \
    libsqlite3-dev \
    libc6-dev \
    libevent-dev \
    libgmp-dev \
    libpcre2-dev \
    libpng-dev \
    libssl-dev \
    libyaml-dev \
    zlib1g-dev

WORKDIR /khodo

FROM crystal_link AS server_bin

COPY --from=server_build /khodo/build/start_server.o /khodo/

RUN cc start_server.o \
    -o start_server \
    -rdynamic \
    -static \
    -L/usr/lib/crystal \
    -lgmp \
    -lyaml \
    -lz \
    `command -v pkg-config > /dev/null && pkg-config --libs --silence-errors libssl || printf %s '-lssl -lcrypto'` \
    `command -v pkg-config > /dev/null && pkg-config --libs --silence-errors libcrypto || printf %s '-lcrypto'` \
    -lpcre2-8 \
    -lm \
    -lgc \
    -lpthread \
    -levent \
    -lrt \
    -lpthread \
    -ldl

FROM crystal_link AS tasks_bin

COPY --from=tasks_build /khodo/build/tasks.o /khodo/

RUN cc tasks.o \
    -o tasks \
    -rdynamic \
    -static \
    -L/usr/lib/crystal \
    -lsqlite3 \
    -lz \
    -lm \
    -lgmp \
    -lyaml \
    -lz \
    `command -v pkg-config > /dev/null && pkg-config --libs --silence-errors libssl || printf %s '-lssl -lcrypto'` \
    `command -v pkg-config > /dev/null && pkg-config --libs --silence-errors libcrypto || printf %s '-lcrypto'` \
    -lpcre2-8 \
    -lm \
    -lgc \
    -lpthread \
    -levent \
    -lrt \
    -lpthread \
    -ldl

FROM --platform=$BUILDPLATFORM node:lts-slim AS static_assets_build

WORKDIR /khodo

COPY ./package.json /khodo/
COPY ./yarn.lock /khodo/
RUN yarn install

COPY ./ /khodo
RUN yarn prod

FROM debian:bookworm-slim AS runtime

RUN apt-get update -q \
  && apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl gnupg ca-certificates \
  && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
  && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
  && apt-get update -q \
  && apt-get install --no-install-recommends -y caddy \
  && apt-get clean -y

WORKDIR /khodo

COPY --from=static_assets_build /khodo/public /khodo/public
COPY --from=server_bin /khodo/start_server /khodo/
COPY --from=tasks_bin /khodo/tasks /khodo/
COPY docker/Caddyfile /khodo/Caddyfile

RUN useradd -ms /bin/bash khodo
USER khodo

CMD ["./start_server"]
