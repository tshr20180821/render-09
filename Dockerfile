FROM php:8.3-apache

EXPOSE 80
SHELL ["/bin/bash", "-c"]
WORKDIR /usr/src/app

COPY --chmod=755 ./start.sh ./

ENTRYPOINT ["/bin/bash","/usr/src/app/start.sh"]
