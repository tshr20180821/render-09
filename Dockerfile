FROM php:8.3-apache

EXPOSE 80

SHELL ["/bin/bash", "-c"]

WORKDIR /usr/src/app

COPY ./php.ini ${PHP_INI_DIR}/

RUN set -x \
 && ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && \
  { \
   echo 'User-agent: *'; \
   echo 'Disallow: /'; \
  } >/var/www/html/robots.txt \
 && docker-php-ext-install sockets \
 && a2enmod -q proxy proxy_connect

COPY --chmod=755 ./app/*.sh ./
COPY ./auth/*.php /var/www/html/auth/

STOPSIGNAL SIGWINCH

ENTRYPOINT ["/bin/bash","/usr/src/app/start_pre.sh"]
