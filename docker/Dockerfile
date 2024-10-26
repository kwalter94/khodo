FROM debian:bookworm-slim AS runtime

USER root
WORKDIR /khodo

RUN apt-get update -q \
  && apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl gnupg ca-certificates \
  && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
  && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
  && apt-get update -q \
  && apt-get install --no-install-recommends -y caddy \
  && apt-get clean -y

FROM runtime AS static_assets_build

RUN apt-get install --no-install-recommends -y npm \
  && npm install -g yarn

COPY ./package.json /khodo/
COPY ./yarn.lock /khodo/
RUN yarn install

COPY ./ /khodo
RUN yarn prod

# Parallelise slow Crystal builds
FROM runtime AS crystal_build

RUN curl -fsSL https://packagecloud.io/84codes/crystal/gpgkey | gpg --dearmor -o /etc/apt/trusted.gpg.d/84codes_crystal.gpg \
  && echo "deb https://packagecloud.io/84codes/crystal/any any main" | tee /etc/apt/sources.list.d/84codes_crystal.list \
  && apt-get update -q \
  && apt-get install --no-install-recommends -y \
    crystal \
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

COPY ./shard.yml /khodo/
COPY ./shard.lock /khodo/
RUN shards install --without-develoment

COPY ./ /khodo

FROM crystal_build AS server_build
RUN crystal build --static --release src/start_server.cr

FROM crystal_build AS tasks_build
RUN crystal build --static --release -o run_tasks tasks.cr

FROM runtime AS final

COPY --from=server_build /khodo/start_server /khodo
COPY --from=tasks_build /khodo/run_tasks /khodo
COPY --from=static_assets_build /khodo/public /khodo/public
COPY docker/Caddyfile /khodo/Caddyfile

RUN useradd -ms /bin/bash khodo
USER khodo

CMD ["./start_server"]
