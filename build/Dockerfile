FROM docker:dind

ENV DOCKER_COMPOSE_VERSION 1.20.1

RUN apk update && \
    apk add xorriso git xz curl iptables && \
    rm -rf /var/cache/apk/*

RUN apk add -U --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing aufs-util

RUN addgroup -g 2999 docker

RUN set -x && \
    apk add --no-cache -t .deps ca-certificates curl && \
    # Install glibc on Alpine (required by docker-compose) from
    # https://github.com/sgerrand/alpine-pkg-glibc
    # See also https://github.com/gliderlabs/docker-alpine/issues/11
    GLIBC_VERSION='2.23-r3' && \
    curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
    curl -Lo glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk && \
    curl -Lo glibc-bin.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk && \
    apk update && \
    apk add glibc.apk glibc-bin.apk && \
    rm -rf /var/cache/apk/* && \
    rm glibc.apk glibc-bin.apk && \
    \
    # Clean-up
    apk del .deps

RUN curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-Linux-x86_64 > /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# Create app directory
WORKDIR /usr/src/app

ADD scripts/* ./
ADD dappnode dappnode
ADD boot boot

#CMD ["/bin/sh"] 
CMD ["/usr/src/app/generate_ISO.sh"] 