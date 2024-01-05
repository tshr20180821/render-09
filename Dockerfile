FROM php:8.3-apache

EXPOSE 80
SHELL ["/bin/bash", "-c"]
WORKDIR /usr/src/app

RUN apt-get -qq update \
 && apt-get install -y --no-install-recommends \
  build-essential \
  distcc \
  iproute2 \
  libsasl2-dev \
  libsasl2-modules \
  netcat-openbsd \
  sasl2-bin \
  zlib1g-dev

COPY --chmod=755 ./*.sh ./

ENTRYPOINT ["/bin/bash","/usr/src/app/start.sh"]
