FROM php:8.3-apache

EXPOSE 80
SHELL ["/bin/bash", "-c"]
WORKDIR /usr/src/app

RUN apt-get -qq update \
 && apt-get install -y --no-install-recommends \
  iproute2

COPY --chmod=755 ./start.sh ./

ENTRYPOINT ["/bin/bash","/usr/src/app/start.sh"]
