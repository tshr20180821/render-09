FROM php:8.3-apache

EXPOSE 80

SHELL ["/bin/bash", "-c"]

WORKDIR /usr/src/app

COPY ./php.ini ${PHP_INI_DIR}/

RUN set -x \
 && apt-get -qq update \
 && DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
  build-essential \
  curl \
  distcc \
  gcc-x86-64-linux-gnu \
  iproute2 \
  libmemcached-dev \
  libpq-dev \
  libsasl2-modules \
  libssl-dev \
  memcached \
  sasl2-bin \
  socat \
  tzdata \
  zlib1g-dev \
  >/dev/null \
 && MAKEFLAGS="-j $(nproc)" pecl install igbinary >/dev/null \
 && MAKEFLAGS="-j $(nproc)" pecl install memcached --enable-memcached-sasl >/dev/null \
 && docker-php-ext-enable \
  igbinary \
  memcached \
  >/dev/null \
 && docker-php-ext-install -j$(nproc) \
  pdo_pgsql \
  sockets  \
  >/dev/null \
 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY --chmod=755 ./app/*.sh ./
COPY ./auth/*.php /var/www/html/auth/

STOPSIGNAL SIGWINCH

ENTRYPOINT ["/bin/bash","/usr/src/app/start.sh"]
