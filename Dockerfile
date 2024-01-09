FROM php:8.3-apache

EXPOSE 80

SHELL ["/bin/bash", "-c"]

WORKDIR /usr/src/app

COPY ./php.ini ${PHP_INI_DIR}/
COPY ./apache.conf /etc/apache2/sites-enabled/

RUN set -x \
 && time apt-get -qq update \
 && time DEBIAN_FRONTEND=noninteractive apt-get -q install -y --no-install-recommends \
  curl \
  distcc \
  iproute2 \
  socat \
 && time apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/www/html/auth \
 && a2dissite -q 000-default.conf \
 && a2enmod -q \
  authz_groupfile \
  proxy \
  rewrite \
 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && chown www-data:www-data /var/www/html/auth -R \
 && echo '<HTML />' >/var/www/html/index.html \
 && \
  { \
   echo 'User-agent: *'; \
   echo 'Disallow: /'; \
  } >/var/www/html/robots.txt

COPY --chmod=755 ./app/*.sh ./
COPY ./auth/*.php /var/www/html/auth/

STOPSIGNAL SIGWINCH

ENTRYPOINT ["/bin/bash","/usr/src/app/start_pre.sh"]
